##
# WHMCS Order
#
# next_step = redirect URL.
#
# products = [{
#   'product_id' => configurable_id,
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
                  :next_step

    def initialize
      @client = Whmcs::Client.new
      self.products = []
    end

    def create!
      return false if self.products.empty?
      return false if self.user.nil?
      order_data = {}
      self.products.each_with_index do |i,k|
        order_data["pid[#{k}]"] = Whmcs.config[:container_product_id]
        order_data["domain[#{k}]"] = i['label']
        items = { i['product_id'].to_i => i['qty'].to_i }
        order_data["configoptions[#{k}]"] = Base64.urlsafe_encode64(PhpSerialization.dump(items))
      end
      # 'paymentmethod' => Whmcs.config[:default_payment_method],
      # 'noinvoice' => !Whmcs.config[:order_invoice],
      # 'noinvoiceemail' => !Whmcs.config[:email_invoice],
      data = {
        'clientid' => self.user.id,
        'clientip' => self.user_ip,
        'paymentmethod' => Whmcs.config[:default_payment_method],
        'noemail' => !Whmcs.config[:email_order]
      }
      data.merge!(order_data)
      response = @client.exec!('AddOrder', data)
      if response['result'] == 'success'
        self.invoice = Whmcs::Invoice.new(response) if response['invoiceid']
        if self.invoice
          goto = @client.authenticated_url({email: self.user.email, goto: "viewinvoice.php?id=#{self.id}"})
          self.next_step = "#{@client.endpoint}/#{goto}"
        end
        true
      else
        self.errors = [response['message']]
        false
      end
    end

    def cancel!
      
    end

    def destroy!
      
    end

  end
end