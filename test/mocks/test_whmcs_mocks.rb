##
# mock our models form ComputeStacks so we can test our interactions
module TestWhmcsMocks
  class Error < StandardError; end

  class User

    attr_accessor :fname,
                  :lname,
                  :active,
                  :address1,
                  :address2,
                  :city,
                  :state,
                  :zip,
                  :country,
                  :phone,
                  :email,
                  :requested_email,
                  :labels

    def initialize
      self.labels = {
        'cpanel' => {
          'mycpanelserver.net' => 'jane.doe3-10@demo.computestacks.net'
        }
      }
      self.active = true
    end

    def save
      true
    end

    def errors
      UserErrors.new
    end

  end

  class UserErrors

    def full_messages
      []
    end

  end

end
