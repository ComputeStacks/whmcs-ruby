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

    ##
    # Process usage items (Create billable items)
    #
    # 
    #
    # [{
    #   :subscription_id=>562,
    #   :subscription_product_id=>569,
    #   :product=>{:id=>4, :name=>"storage", :external_id=>nil, :unit=>1},
    #   :billing_resource=>{:id=>4, :external_id=>nil, :billing_plan=>1},
    #   :container_service_id=>433,
    #   :container_id=>625,
    #   :device_id=>nil,
    #   :user=>{:id=>1, :external_id=>"2", :email=>"kris@computestacks.com"},
    #   :external_id=>nil,
    #   :total=>0.0882,
    #   :qty=>0.882,
    #   :period_start=>TimeInUTC,
    #   :period_end=>TimeInUTC,
    #   :usage_items=>
    #     [
    #       {:id=>33, :rate=>0.1, :qty=>0.221, :total=>0.0221, :period_start=>TimeInUTC, :period_end=>TimeInUTC}
    #     ]
    #   }]
    def self.process_usage!(usage_items = [])      
      client = Whmcs::Client.new
      # Collect subscription IDs
      # subscription_ids = []
      # usage_items.each do|i|
      #   next if i[:external_id].nil?
      #   subscription_ids << i[:external_id] unless subscription_ids.include?(i[:external_id])
      # end
      user_ids = []
      usage_items.each do |i|
        next if i[:user].nil? || i[:user][:external_id].nil?
        user_ids << i[:user][:external_id] unless user_ids.include?(i[:user][:external_id])
      end
      billables = []
      # Aggregate usage by external_id
      # Ignore items that have no external_id
      user_ids.each do |i|
        products = []        
        usage_items.each do |item|
          if item[:user] && i[:user][:external_id] == i
            products << item[:product][:id] unless products.include?(item[:product][:id])
          end
        end
        products.each do |p|
          total = 0.0
          qty = 0.0
          product = nil
          usage_items.each do |item|
            next if item[:user].nil? || item[:user][:external_id] != i
            total += item[:total]
            qty += item[:qty]
            product = item[:product][:name] unless item[:product].nil?
          end
          billables << { total: total, qty: qty , client_id: i, product: product } unless product.nil? || total.zero?
        end        
      end

      # Due Date
      t = Time.new(Time.now.utc.year,Time.now.utc.month)+45*24*3600
      due_date = Time.new(t.year, t.month, 1).strftime('%Y-%m-%d')
      errors = []
      # Generate Billable Items
      billables.each do |i|
        data = {
          'clientid' => i[:client_id],
          'description' => i[:product],
          'amount' => i[:total],
          'invoiceaction' => 'duedate',
          'duedate' => due_date,
          'hours' => i[:qty]
        }
        result = client.exec!('AddBillableItem', data)
        if result['result'] == 'success'
          next
        else
          errors << result['message']
          next
        end
      end
      if errors.empty?
        { 'success' => true }
      else
        { 'success' => false, 'errors' => errors}
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
        if response['invoiceid'] && response['invoiceid'].to_i > 0
          Whmcs.logger.info "Subscription Modification - Loading Invoice: #{response['invoiceid'].to_i}"
          new_invoice = Whmcs::Invoice.find(response['invoiceid'], false)
          if new_invoice && new_invoice.status == 'unpaid'
            self.load! if self.user.nil?
            if self.user && self.user.email
              Whmcs.logger.info "Subscription Modification - Loading Redirect URL"
              new_order.next_step = @client.authenticated_url({email: self.user.email, goto: "viewinvoice.php?id=#{response['invoiceid']}"})
            end
          end   
          new_order.invoice = new_invoice      
        end
        new_order
      end
    rescue => e
      {'error' => e.to_s}
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