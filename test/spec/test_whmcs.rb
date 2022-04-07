require_relative '../helper'

describe Whmcs do

  describe "module setup" do

    before do
      Whmcs.configure(
        endpoint: ENV['WHMCS_ENDPOINT'],
        api_key: ENV['WHMCS_API_KEY'],
        api_secret: ENV['WHMCS_API_SECRET'],
        access_key: ENV['WHMCS_API_ACCESS_KEY'],
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
      d = Whmcs.test_connection! true
      puts d[:message] unless d[:success]
      assert d[:success]
    end

  end

end
