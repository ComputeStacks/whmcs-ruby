module Whmcs
  ##
  # Base class for our plugin
  class Base

    def initialize(args = {})
      args.each do |key, value|
        send("#{key}=", value)
      end
    end

    ##
    # Initiate remote api calls to WHMCS
    def remote(action, data = {})
      raise Whmcs::Error.new 'Plugin not configured' unless configured?
      api_endpoint = "https://#{sanitized_endpoint}/includes/api.php"
      body = {
        action: action,
        identifier: Whmcs.config[:api_key],
        secret: Whmcs.config[:api_secret],
        responsetype: 'json'
      }
      unless Whmcs.config[:access_key].blank?
        body[:accesskey] = Whmcs.config[:access_key]
      end
      body.merge!(data) unless data.empty?
      Faraday.post(api_endpoint, body)
    end

    private

    ##
    # Perform some basic sanity checks on the endpoint
    def sanitized_endpoint
      return nil if Whmcs.config[:endpoint].blank?
      e = Whmcs.config[:endpoint].split('://').last # remove all protocol definitions
      e[-1] == '/' ? e[0..-2] : e # Remove trailing '/'.
    end

    ##
    # Simple sanity check to make sure our required parameters are not blank
    def configured?
      !(Whmcs.config[:api_key].blank? || Whmcs.config[:api_secret].blank? || Whmcs.config[:endpoint].blank?)
    end

  end
end
