##
# Invoice
# 
# All fields required.
#
module Whmcs
  class Invoice

    attr_accessor :id,
                  :invoice_number,
                  :user,
                  :date,
                  :due,
                  :total,
                  :subtotal,
                  :balance,
                  :tax,
                  :tax2,
                  :credit,
                  :status,
                  :items,
                  :details

    def initialize(data = {})
      @client = Whmcs::Client.new
      self.id = data['invoiceid'] if !data.empty? && data['invoiceid']
      self.items = []
    end

    # Format remote invoice data
    def load!(load_user, data = {})
      return false if data.empty? && self.id.nil?
      if data.empty?
        invoice_data = @client.exec!('GetInvoice', { 'invoiceid' => self.id })
        return nil unless invoice_data['result'] == 'success'
      else
        invoice_data = data
      end
      the_user = Whmcs::User.new
      the_user.id = invoice_data['userid']
      the_user.load! if load_user
      self.id = invoice_data['invoiceid']
      self.invoice_number = invoice_data['invoicenum']
      self.user = the_user
      self.date = invoice_data['date']
      self.due = invoice_data['duedate']
      self.subtotal = invoice_data['subtotal'].to_f
      self.credit = invoice_data['credit'].to_f
      self.tax = invoice_data['tax'].to_f
      self.tax2 = invoice_data['tax2'].to_f
      self.total = invoice_data['total'].to_f
      self.balance = invoice_data['balance'].to_f
      self.status = invoice_data['status'].downcase
      invoice_data['items']['item'].each do |i|
        self.items << Whmcs::InvoiceItem.new(i)
      end
      self.details = {
        date_paid: invoice_data['datepaid'],
        last_capture_attempt: invoice_data['lastcaptureattempt'],
        tax_rate: invoice_data['taxrate'],
        tax2_rate: invoice_data['taxrate2'],
        payment_method: invoice_data['paymentmethod'],
        notes: invoice_data['notes']
      }
      true
    end

    ##
    # Find an Invoice by its ID.
    #
    # You can optionally disable loading the user data for large 'expensive', api calls.
    def self.find(id, load_user = true)
      return nil unless id.to_i > 0
      invoice = self.new({ 'invoiceid' => id })
      invoice.load!(load_user, {})
      invoice
    end

  end
end