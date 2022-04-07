require_relative '../helper'

describe Whmcs::User do

  describe "loading a user from WHMCS" do

    before do
      Whmcs.configure(
        endpoint: ENV['WHMCS_ENDPOINT'],
        api_key: ENV['WHMCS_API_KEY'],
        api_secret: ENV['WHMCS_API_SECRET'],
        access_key: ENV['WHMCS_API_ACCESS_KEY']
      )
    end

    it 'can find by clientid' do
      user = Whmcs::User.find_by_id ENV['WHMCS_TEST_USER_ID']
      assert_kind_of Whmcs::User, user
      assert_equal ENV['WHMCS_TEST_USER_ID'].to_i, user.id
    end

    it 'can find by email' do
      user = Whmcs::User.find_by_email('jane.doe@example.com')
      assert_kind_of Whmcs::User, user
      assert_equal 'jane.doe@example.com', user.email
    end

  end

end
