class Whmcs::Sso

  def self.auth_user!(email, password)
    client = Whmcs::Client.new
    raise Whmcs::NotImplemented, 'SSO is disabled.' unless Whmcs.config.enable_sso
    raise Whmcs::MissingParameter, "Missing required parameters" if client.nil? || email.nil? || password.nil?
    data = {
      email: email,
      password2: password
    }
    client.exec!('ValidateLogin', data)
  end

end