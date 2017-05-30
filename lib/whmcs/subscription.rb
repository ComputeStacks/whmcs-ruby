module Whmcs
  class Subscription

    attr_accessor :id,
                  :name,
                  :label,
                  :created_at,
                  :product_id,
                  :active,
                  :status,
                  :next_due_date,
                  :term,
                  :qty,
                  :user,
                  :details,
                  :errors

    def initialize(data = {})
      @client = Whmcs::Client.new
      self.errors = []
      self.details = {} # Custom Settings specific for this module.
      load!(data) unless data.empty?
    end

    def load!(data = {})
      return nil if data.empty? && self.id.nil?
      if data.empty?
        data = @client.exec!('GetClientsProducts', { 'serviceid' => self.id })['products']['product'][0]
      end
      self.user = Whmcs::User.find(data['clientid'])
      self.id = data['id']
      self.created_at = Time.parse(data['regdate'])
      self.name = data['name']
      self.label = data['domain']
      self.product_id = data['pid']
      self.active = data['status'] == 'Active'
      self.status = data['status']
      self.term = data['billingcycle']
      self.next_due_date = data['nextduedate']
      self.qty = format_qty(data['configoptions']['configoption'])
      self.details = {
        paymentmethod: data['paymentmethod'],
        qty_config_id: qty_config_id(data['configoptions']['configoption'])
      }
    end

    ##
    # Generic helper to update basic settings.
    def save
      update!
    end

    ##
    # Update a Subscription. To change product / qty, use  `modify!()`
    def update!
      data = {
        'serviceid' => self.id,
        'domain' => self.label
      }
      result = @client.exec!('UpdateClientProduct', data)
      if result['result'] == 'success'        
        true
      else
        self.errors << result['message'] if result['message']
        false
      end
    end

    def create!
      raise Whmcs::NotImplemented, 'To create a service, please place an order.'
    end

    ##
    # Upgrade/Downgrade a product or QTY
    #
    # dry_run: Only return calculated changes.
    #
    # Returns Hash for DryRun, or Whmcs::Order for complete process
    def modify!(new_product_id, new_qty, change_billing_cycle, dry_run = false)
      return false if new_qty.nil? && new_product_id.nil?
      data = {
        'serviceid' => self.id,
        'paymentmethod' => self.details[:paymentmethod].nil? ? Whmcs.config[:default_payment_method] : self.details[:paymentmethod],
        'type' => new_product_id.nil? ? 'configoptions' : 'product'
      }
      data['newproductbillingcycle'] = self.term if change_billing_cycle
      data['calconly'] = true if dry_run
      if new_product_id
        # Product Change
        data['newproductid'] = new_product_id
        data['newproductbillingcycle'] = self.term.nil? ? 'Monthly' : self.term
      elsif new_qty.to_i > 0
        # QTY Change
        data["configoptions[#{self.details[:qty_config_id]}]"] = new_qty
      else
        return {'success' => false, 'message' => 'Missing ProductID or QTY change.'}
      end
      response = @client.exec!('UpgradeProduct', data)
      unless response['result'] == 'success'
        result = { 'success' => false, 'message' => response.body.to_s }
        result.merge!(data)
        return result
      end
      if dry_run
        {
          'from' => "#{response['originalvalue1']} x #{response['configname1']}",
          'to' => response['newvalue1'],
          'price' => response['price1']
        }
      else
        new_order = Whmcs::Order.new
        new_order.id = response['orderid']
        if response['invoiceid'] && !response['invoiceid'].zero?
          new_order.invoice = Whmcs::Invoice.find(response['invoiceid'])
          if new_order.invoice
            self.load! if self.user.nil?
            new_order.next_step = @client.authenticated_url({email: self.user.email, goto: "viewinvoice.php?id=#{response['invoiceid']}"})
          end          
        end
        new_order
      end
    end


    ##
    # Cancel a subscription
    def cancel!
      @client.exec!('AddCancelRequest', { 'serviceid' => self.id, 'type' => 'Immediate' })
    end

    def self.find(id)
      client = Whmcs::Client.new
      result = client.exec!('GetClientsProducts', { 'serviceid' => id })
      return nil if result['result'] != 'success' || result['products'].empty?
      Whmcs::Subscription.new(result['products']['product'][0])
    rescue
      nil
    end

    private

    ##
    # Determine Quantity
    #
    #
    def format_qty(config_options)
      qty = 1
      config_options.each do |i|
        if i['option'] == 'Container' && i['type'] == 'quantity'
          qty = i['value']
          break
        end
      end
      qty
    end

    ##
    # Return configid of the Quantity Config Option
    #
    def qty_config_id(config_options)
      config_options.each do |i|
        if i['option'] == 'Container' && i['type'] == 'quantity'
          return i['id']
        end
      end
    end

  end
end