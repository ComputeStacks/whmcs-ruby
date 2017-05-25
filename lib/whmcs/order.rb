##
# WHMCS Order
#
# next_step = redirect URL.
#
# products = [{
#   'product_id' => product_external_id,
#   'billing_resource_id' => external_id,
#   'label' => service_name,
#   'qty' => 1
# }]
#
module Whmcs
  class Order

    attr_accessor :id,
                  :user,
                  :products,
                  :invoice,
                  :user_ip,
                  :errors,
                  :next_step,
                  :result,
                  :service_ids # Resulting services created

    def initialize
      @client = Whmcs::Client.new
      self.products = []
      self.service_ids = []
    end

    def create!
      return false if self.products.empty?
      return false if self.user.nil?
      order_data = {}
      self.products.each_with_index do |i,k|
        order_data["pid[#{k}]"] = i['product_id'].to_i
        order_data["hostname[#{k}]"] = i['label'] unless i['label'].nil? || i['label'].blank?
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
      data.merge!(order_data)
      response = @client.exec!('AddOrder', data)
      self.result = response
      if response['result'] == 'success'
        self.invoice = Whmcs::Invoice.new(response) if response['invoiceid']
        self.id = response['orderid']
        if self.invoice
          goto = @client.authenticated_url({email: self.user.email, goto: "viewinvoice.php?id=#{self.id}"})
          self.next_step = "#{@client.endpoint}/#{goto}"
        end
        self.service_ids = response['productids'].split(',').map { |s| s.to_i } if response['productids']
        true
      else
        (self.errors ||= []) << response['message']
        false
      end
    end

    def cancel!
      
    end

    def destroy!
      
    end

  end
end