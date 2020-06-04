require_relative '../helper'

describe Whmcs::User do

  describe "loading a user from WHMCS" do

    before do
      Whmcs.configure(
        endpoint: ENV['WHMCS_ENDPOINT'],
        api_key: ENV['WHMCS_API_KEY'],
        api_secret: ENV['WHMCS_API_SECRET']
      )
    end

    it 'can find by clientid' do
      VCR.use_cassette("user_find_by_id") do
        user = Whmcs::User.find_by_id(3)
        assert_kind_of Whmcs::User, user
        assert_equal 3, user.id
      end
    end

    it 'can find by email' do
      VCR.use_cassette("user_find_by_email") do
        user = Whmcs::User.find_by_email('jane.doe@example.com')
        assert_kind_of Whmcs::User, user
        assert_equal 'jane.doe@example.com', user.email
      end
    end

  end

end
