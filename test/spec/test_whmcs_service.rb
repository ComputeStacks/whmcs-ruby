require_relative '../helper'

describe Whmcs::Service do

  describe "loading a user from WHMCS" do

    before do
      Whmcs.configure(
        endpoint: ENV['WHMCS_ENDPOINT'],
        api_key: ENV['WHMCS_API_KEY'],
        api_secret: ENV['WHMCS_API_SECRET'],
        access_key: ENV['WHMCS_API_ACCESS_KEY']
      )
    end

    it 'can find a valid user given a username' do
      result = Whmcs::Service.find_all_by_username('jane.doe3-10@demo.computestacks.net')
      assert_kind_of Whmcs::Service, result.first
    end

    it 'can change the username of a service' do
      service = Whmcs::Service.find ENV['WHMCS_TEST_SERVICE_ID']
      service.username = "tester332@demo.computestacks.net"
      assert service.save

      # Check service to make sure it actually saved
      check_service = Whmcs::Service.find ENV['WHMCS_TEST_SERVICE_ID']
      assert_equal "tester332@demo.computestacks.net", check_service.username

      # Put the username back!
      check_service.username = "jane.doe3-10@demo.computestacks.net"
      assert check_service.save
    end

    it 'can load a service' do
      service = Whmcs::Service.find ENV['WHMCS_TEST_SERVICE_ID']
      refute_nil service
      assert_equal 'jane.doe3-10@demo.computestacks.net', service.username
    end

  end

end
