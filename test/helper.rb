require 'bundler/setup'
Bundler.require(:default, :test)

require 'mocks/test_whmcs_mocks'

require 'minitest/autorun'
require "minitest/reporters"
require 'vcr'
require 'yaml'

require 'whmcs'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

VCR.configure do |config|
  config.cassette_library_dir = "test/fixtures/vcr"
  config.hook_into :faraday
  config.filter_sensitive_data('<WHMCS_ENDPOINT>') { ENV['WHMCS_ENDPOINT'] }
  config.filter_sensitive_data('<WHMCS_API_KEY>') { ENV['WHMCS_API_KEY'] }
  config.filter_sensitive_data('<WHMCS_API_SECRET>') { ENV['WHMCS_API_SECRET'] }
end
