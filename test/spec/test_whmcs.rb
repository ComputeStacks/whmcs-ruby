require_relative '../helper'

describe Whmcs do

  describe "module setup" do

    before do
      Whmcs.configure(
        endpoint: ENV['WHMCS_ENDPOINT'],
        api_key: ENV['WHMCS_API_KEY'],
        api_secret: ENV['WHMCS_API_SECRET'],
        invalid_key: 'nope',
        due_date: '1'
      )
    end

    it "can be configured" do
      assert_equal Whmcs.config[:endpoint], ENV['WHMCS_ENDPOINT']
      assert_equal Whmcs.config[:api_key], ENV['WHMCS_API_KEY']
      assert_equal Whmcs.config[:api_secret], ENV['WHMCS_API_SECRET']
      assert_nil Whmcs.config[:invalid_key]
      assert_equal Whmcs.config[:due_date], '1'
    end

    it "can test it's connection" do
      VCR.use_cassette "get_health_status" do
        assert Whmcs.test_connection!
      end
    end

  end

end
