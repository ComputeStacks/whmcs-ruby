require_relative '../helper'

describe Whmcs::Service do

  describe "loading a user from WHMCS" do

    before do
      Whmcs.configure(
        endpoint: ENV['WHMCS_ENDPOINT'],
        api_key: ENV['WHMCS_API_KEY'],
        api_secret: ENV['WHMCS_API_SECRET']
      )
    end

    it 'can find a valid user given a username' do
      VCR.use_cassette("get_client_products") do
        result = Whmcs::Service.find_all_by_username('jane.doe3-10@demo.computestacks.net')
        assert_kind_of Whmcs::Service, result.first
      end
    end

  end

end
