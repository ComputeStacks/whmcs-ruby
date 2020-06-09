module Whmcs
  ##
  # Process usage data from ComputeStacks
  class Usage < Base

    attr_accessor :billable_items,
                  :errors

    def initialize(raw_data = [])
      self.billable_items = []
      self.errors = []
      aggregate_usage!(raw_data) unless raw_data.empty?
    end

    ##
    # Create billable items in WHMCS
    def save
      t = Time.new(Time.now.utc.year,Time.now.utc.month)+45*24*3600
      due_date = Time.new(t.year, t.month, 1).strftime('%Y-%m-%d')
      # Generate Billable Items
      billable_items.each do |i|
        # Data format sent to WHMCS.
        data = {
          'clientid' => i[:client_id],
          'description' => i[:product],
          'amount' => i[:total],
          'invoiceaction' => 'duedate',
          'duedate' => due_date,
          'hours' => i[:qty]
        }
        # Intentionally not including this so we can capture the exception in CS.
        response = remote('AddBillableItem', data)
        begin
          result = Oj.load(response.body, { symbol_keys: true, mode: :object })
          self.errors << result[:message] unless result[:result] == 'success'
        rescue
          # probably a failure anyways
          self.errors << "Fatal error reporting usage to WHMCS."
        end
      end
      errors.empty?
    end

    private

    ##
    # Format data provided by ComputeStacks, for WHMCS
    def aggregate_usage!(data)
      # Collect all WHMCS users IDs
      user_ids = []
      data.each do |i|
        clientid = i.dig(:user, :labels, 'whmcs', 'client_id')
        if clientid.blank?
          # check for legacy external_id
          clientid = i.dig(:user, :external_id)
          next if clientid.blank?
          # if we have a valid ID and service_id does not exist, then this is a legacy client id, so we can use that.
          next unless i.dig(:user, :labels, 'whmcs', 'service_id').blank?
        end
        clientid = clientid.to_i # ensure we always have an int
        user_ids << clientid unless user_ids.include?(clientid)
        # Now set our copy of the data to include the clientid as the external id. We will use this later to verify the output
        i[:user][:external_id] = clientid
      end

      billables = []
      user_ids.each do |i|
        products = []
        data.each do |item|
          if item[:user] && item[:user][:external_id] == i
            products << item[:product][:name] unless products.include?(item[:product][:name])
          end
        end
        products.each do |p|
          total = 0.0
          qty = 0.0
          data.each do |item|
            next if item[:user].nil? || item[:user][:external_id] != i
            next unless item[:product][:name] == p
            total += item[:total]
            qty += item[:qty]
          end
          billables << { total: total.round(2), qty: qty , client_id: i, product: p } unless total.zero?
        end
      end
      self.billable_items = billables
    end

  end
end
