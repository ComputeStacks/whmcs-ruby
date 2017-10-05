##
# InvoiceItem
#
# All fields required.
#
module Whmcs
  class InvoiceItem

    attr_accessor :id,
                  :description,
                  :tax,
                  :amount

    def initialize(data = {})
      load!(data) unless data.empty?
    end

    def load!(data)
      return false if data.nil? || data.empty?
      self.id = data['id']
      self.description = data['description']
      self.amount = data['amount']
      self.tax = data['taxed']
    end

  end
end