# endpoint: example https://my-whmcs.com
# api_key: admin username, or api identifier.
# api_secret: secret api key, or password.
# legacy_login: [true|false] true if using the whmcs password 
# shared_secret: used for autoauth
#
module Whmcs
  class Client
    
    attr_accessor :endpoint,
                  :api_key,
                  :api_secret,
                  :shared_secret

    def initialize
      self.api_secret = Whmcs.config[:legacy_login] ? Digest::MD5.hexdigest(Whmcs.config[:api_secret]) : Whmcs.config[:api_secret]
      self.endpoint = Whmcs.config[:endpoint]
      self.api_key = Whmcs.config[:api_key]
      self.shared_secret = Whmcs.config[:shared_secret]
    end

    def exec!(action, data = {})
      options = {        
        action: action,
        responsetype: 'json'
      }
      if Whmcs.config[:legacy_login]
        options[:username] = api_key
        options[:password] = api_secret
      else
        options[:identifier] = api_key
        options[:secret] = api_secret
      end
      if Whmcs.config[:access_key]
        options[:accesskey] = Whmcs.config[:access_key]
      end
      options.merge!(data) unless data.nil? || data.empty?
      data = URI.encode_www_form(options)
      response = HTTParty.post("#{self.endpoint}/includes/api.php", body: data)
      raise Whmcs::AuthenticationFailed, response['message'] if response['result'] == 'error' && response['message'] =~ /Invalid IP/
      response
    end

    ##
    # Generate authenticated url for WHMCS
    #
    # add `$autoauthkey = "abcXYZ123";` to `configuration.php`
    #
    # http://docs.whmcs.com/AutoAuth
    #
    def authenticated_url(params = {})
      raise Whmcs::InvalidParameter, 'Passed paramaters should be a hash' unless params.is_a?(Hash)
      raise Whmcs::MissingParameter, 'Missing Shared Secret' if self.shared_secret.nil?
      email = params[:email]
      goto = params[:goto]
      raise Whmcs::MissingParameter, 'Missing Email' if email.nil?
      raise Whmcs::MissingParameter, 'Missing goto URL' if goto.nil?
      ts = Time.now.to_i
      token = Digest::SHA1.hexdigest("#{email}#{ts}#{self.shared_secret}")
      "#{self.endpoint}/dologin.php?email=#{email}&timestamp=#{ts}&hash=#{token}&goto=#{CGI::escape(goto)}"
    end

  end
end