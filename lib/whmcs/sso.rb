module Whmcs
  class Sso

    def self.auth_user!(email, password)
      client = Whmcs::Client.new
      raise Whmcs::NotImplemented, 'SSO is disabled.' unless Whmcs.config[:enable_sso]
      raise Whmcs::MissingParameter, "Missing required parameters" if client.nil? || email.nil? || password.nil?
      data = {
        email: email,
        password2: password
      }
      response = client.exec!('ValidateLogin', data)
      user = Whmcs::User.new
      if response['result'] == 'success'
        user.id = response['userid']
        user.load!
      else
        user.errors = [response.to_s]
      end
      user
    end

  end
end