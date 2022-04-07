require 'bundler/setup'
Bundler.require(:default, :test)

require 'mocks/test_whmcs_mocks'

require 'minitest/autorun'
require "minitest/reporters"
require 'erb'
require 'yaml'

require 'whmcs'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

