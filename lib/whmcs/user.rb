module Whmcs
  class User

    attr_accessor :id,
                  :fname,
                  :lname,
                  :company,
                  :email,
                  :address1,
                  :address2,
                  :city,
                  :state,
                  :zip,
                  :country,
                  :phone,
                  :errors,
                  :active,
                  :credits,
                  :balance,
                  :details, # Module specific data
                  :new_password # Place holder to set new password.

    def initialize(userdata = nil)
      @client = Whmcs::Client.new
      self.errors = []
      self.details = {}
      self.load!(userdata) unless userdata.nil?
    end

    def load!(userdata = nil)
      return nil if self.id.nil? && userdata.nil?
      response = userdata.nil? ? @client.exec!('GetClientsDetails', { 'clientid' => self.id }) : userdata
      return nil unless response['result'] == 'success'
      data = response['client']
      self.id = data['id']
      self.email = data['email']
      self.fname = data['firstname']
      self.lname = data['lastname']
      self.email = data['email']
      self.address1 = data['address1']
      self.address2 = data['address2']
      self.city = data['city']
      self.state = data['statecode']
      self.zip = data['postcode']
      self.country = data['countrycode']
      self.phone = data['phonenumber']
      self.active = data['status'] == 'Active'
      self.credits = data['credit'].to_f
      self.details = {
        last_login: data['lastlogin'],
        group_id: data['groupid'],
        two_factor_auth: data['twofaenabled'],
        user_id: data['userid'],
        uuid: data['uuid'],
        tax_exempt: data['taxexempt']
      }
      true
    end

    def save
      self.id.nil? ? create! : update!
    end

    def create!
      data = {
        firstname: self.fname,
        lastname: self.lname,
        email: self.email,
        companyname: self.company,
        address1: self.address1,
        address2: self.address2,
        city: self.city,
        state: self.state,
        postcode: self.zip,
        country: self.country,
        phonenumber: self.phone,
        password2: self.new_password.nil? ? SecureRandom.base64(8) : self.new_password
      }
      response = @client.exec!('AddClient', data)
      if response['result'] && response['result'] == 'success'
        self.id = response['clientid']
        true
      else
        self.errors = [response['message']]
        false
      end
    end

    def update!
      data = {
        clientid: self.id,
        firstname: self.fname,
        lastname: self.lname,
        email: self.email,
        companyname: self.company,
        address1: self.address1,
        address2: self.address2,
        city: self.city,
        state: self.state,
        postcode: self.zip,
        country: self.country.nil? ? 'US' : self.country,
        phonenumber: self.phone,
      }
      data[:password2] = self.new_password unless self.new_password.nil?      
      response = @client.exec!('UpdateClient', data)
      if response['result'] == 'success'
        true
      else
        self.errors = [response['message']]
        false
      end
    end

    def change_password!(generate_random = true)
      if self.new_password.nil? && !generate_random
        return false
      elsif self.new_password.nil? && generate_random
        self.new_password = SecureRandom.base64(8)
      end
      data = {
        clientid: self.id,
        password2: self.new_password
      }
      response = @client.exec!('UpdateClient', data)
      if response['result'] == 'success'
        true
      else
        self.errors = [response['message']]
        false
      end
    end

    ## Class Functions ####

    def self.find(id, email = nil)
      if id
        data = { 'clientid' => id }
      elsif email
        data = { 'email' => email }
      else
        return nil
      end    
      result = Whmcs::Client.new.exec!('GetClientsDetails', data)
      return nil if result['result'] != 'success'
      self.new(result)
    end

    def self.all(limit_start, limit)
      search(limit_start, limit)
    end

    def self.search(limit_start, limit, search_param = nil)
      data = nil 
      if limit_start
        data = {
          limitstart: limit_start,
          limitnum: limit
        }
        data[:search] = search_param if search_param
      end        
      result = []
      response = Whmcs::Client.new.exec!('GetClients', data)
      return [] if response['clients'].nil? || response['clients'].empty?
      response['clients']['client'].each do |u|
        user = self.new
        user.id = u['id']
        user.fname = u['firstname']
        user.lname = u['lastname']
        user.company = u['company']
        user.email = u['email']
        result << user
      end
      result
    end

  end
end