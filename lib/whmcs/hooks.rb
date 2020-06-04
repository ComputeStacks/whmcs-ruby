module Whmcs
  ##
  # Hooks allow you to extend your module into different aspects of ComputeStacks.
  #
  # Available Hooks:
  #
  # user_created:
  # * params: User model. This allows you to access the user object and make changes to the user
  #
  # process_usage:
  # * params: Array of Hashes | aggregated usage data for the month. This will be triggered on the last day of the month.
  #
  class Hooks < Base

    attr_accessor :errors

    def initialize
      self.errors = []
    end

    ##
    # UserCreated hook
    #
    # This hook receives the full user Model from ComputeStacks. You can make changes to the user using this.
    #
    def user_created(model)
      success, errors = Whmcs::Service.link_user_by_username model
      return true if success
      self.errors =+ errors
      false
    end

    ##
    # ProcessUsage Hook
    #
    # Take the raw aggregated billing data from ComputeStacks and process it
    #
    def process_usage(raw_data)
      usage = Whmcs::Usage.new(raw_data)
      return true if usage.billable_items.empty?
      result = usage.save
      self.errors += usage.errors
      errors.empty? && result
    end

  end
end
