##
# Single Sign On (optional)
#
# If SSO is enabled for your integration, all non-admin users will be authenticated using this method.
# Additionally, any password changes made in ComputeStacks will be updated remotly with your integration.
#
# 2FA (Authy) will still be handled by ComputeStacks and will be an additional step to login.
#
module Whmcs
  class Sso

    ##
    # Authenticate User
    #
    # If it's a successful authentication, the User class with a valid ID is returned. 
    # No ID & errors not empty = Invalid Authentication
    #
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