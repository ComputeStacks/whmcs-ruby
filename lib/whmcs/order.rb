##
# Order
#
# All fields required.
#
# products = [{
#   'product_id' => product_external_id, # For containers, this references the primary container product (with a price of $0.00)
#   'billing_resource_id' => external_id, ## For Containers, this references the configurable product (Which sets price based on QTY). Not used for Servers.
#   'label' => service_name,
#   'qty' => 1
# }]
#
module Whmcs
  class Order

    attr_accessor :id,
                  :status, # Available Statuses: pending, active, suspended, terminated, cancelled, fraud
                  :user,
                  :products,
                  :invoice,
                  :user_ip,
                  :errors,
                  :promocode,
                  :next_step, # This is the Redirect URL. This will forward the user to your final checkout process.
                  :result,
                  :service_ids # Resulting services created

    def initialize
      @client = Whmcs::Client.new
      self.status = 'pending'
      self.products = []
      self.service_ids = []
      self.promocode = nil
    end

    # Create a new order. This step needs to set locally:
    #
    # - invoice (if one is generated)
    # - next_step (if necessary, otherwise will instantly provision service)
    # - service_ids: An array of IDs: example => [1,2,3,4,5] or just 1: [5]
    # - result : Store the raw result -> this is helpful for debugging purposes.
    #
    def create!
      return false if self.products.empty?
      return false if self.user.nil?
      order_data = {}
      self.products.each_with_index do |i,k|
        order_data["pid[#{k}]"] = i['product_id'].to_i
        order_data["hostname[#{k}]"] = i['label'] unless i['label'].nil? || i['label'].to_s == ''
        items = { i['billing_resource_id'].to_i => i['qty'].to_i }
        order_data["configoptions[#{k}]"] = Base64.urlsafe_encode64(PhpSerialization.dump(items))
      end
      data = {
        'clientid' => self.user.id,
        'paymentmethod' => Whmcs.config[:default_payment_method]
      }
      data['clientip'] = self.user_ip if self.user_ip
      data['noemail'] = true unless Whmcs.config[:email_order]
      data['noinvoice'] = true unless Whmcs.config[:order_invoice]
      data['noinvoiceemail'] = true unless Whmcs.config[:email_invoice]
      data['promocode'] = self.promocode if self.promocode
      data.merge!(order_data)
      response = @client.exec!('AddOrder', data)
      self.result = response
      if response['result'] == 'success'
        self.id = response['orderid']
        if response['invoiceid']
          self.invoice = Whmcs::Invoice.new(response)
          self.next_step = @client.authenticated_url({email: self.user.email, goto: "viewinvoice.php?id=#{response['invoiceid']}"})
        end
        self.service_ids = response['productids'].split(',').map { |s| s.to_i } if response['productids']
        true
      else
        (self.errors ||= []) << response['message']
        false
      end
    end

    # Find an order by its an ID.
    #
    # Currently this is not used and can be omitted, but may be at some point in the future.
    #
    def self.find(order_id)
      client = Whmcs::Client.new
      order_data = client.exec!('GetOrders', { 'id' => order_id })
      if order_data['result'] == 'success' && order_data['totalresults'].to_i > 0
        data = order_data['orders']['order'].first
        order = self.new
        order.status = data['status'].downcase
        order.user = Whmcs::User.find(data['userid'])
        order
      else
        nil
      end
    end

  end
end
