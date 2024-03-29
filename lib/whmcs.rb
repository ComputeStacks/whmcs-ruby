require "active_support"
require "active_support/core_ext/object/blank"
require "faraday"

require "whmcs/base"
require "whmcs/hooks"
require "whmcs/service"
require "whmcs/usage"
require "whmcs/user"
require "whmcs/version"

if RUBY_ENGINE == 'ruby' and not ENV['DISABLE_OJ']
  require 'oj'
  Oj.mimic_JSON
end

module Whmcs
  class Error < StandardError; end

  ##
  # Define settings for the user to provide
  #
  # The order of the fields is determined by their position in the list.
  #
  # Fields:
  #
  # name: must be lower case, no numbers, spaces, or special characters (except _).
  # label: The name of the field shown in the UI
  # description: Displayed under the field to help the user
  # field_type:
  #   * string | Short text field
  #   * text | Textarea
  #   * password | Will store result encrypted and use a password field on the UI
  #   * checkbox | Will display a checkbox and store it as a boolean value
  #   * dropdown | Presents a list of values
  #
  @settings = [
    {
      name: 'endpoint',
      label: 'WHMCS URL',
      description: 'example: whmcs.mysite.com',
      field_type: 'string',
      default: ''
    },
    {
      name: 'api_key',
      label: 'API Key',
      description: '',
      field_type: 'string',
      default: ''
    },
    {
      name: 'api_secret',
      label: 'API Secret',
      description: '',
      field_type: 'password',
      default: ''
    },
    {
      name: 'access_key',
      label: 'API Access Key',
      description: '(optional) access key to bypass WHMCS api IP restrictions',
      field_type: 'password',
      default: ''
    },
    {
      name: 'due_date',
      label: 'Invoice Due Day of Month',
      description: 'What day of the month should the invocie be due? All invoices are generated on the 1st of the month.',
      field_type: 'string',
      default: '1'
    },
    {
      name: 'invoice_on',
      label: 'When to generate invoices',
      description: 'By default, we will invoice on the due date. Alternatively, you can set this to nextcron.',
      field_type: 'string',
      default: 'duedate'
    }
  ]

  @config = @settings.map { |i| { i[:name].to_sym => nil } }.reduce Hash.new, :merge
  @valid_config_keys = @config.keys

  class << self

    def config
      @config
    end

    def settings
      @settings
    end

    def configure(opts = {})
      opts.each {|k,v| @config[k.to_sym] = v if @valid_config_keys.include? k.to_sym}
    end

    ##
    # Test the connection to the integration
    #
    # Should return boolean (true|false)
    # if you pass `true`, you'll get a hash: {success:bool, message:hash or string}
    #
    def test_connection!(include_message = false)
      response = Whmcs::Base.new.remote('GetHealthStatus')
      return response.success? unless include_message
      d = Oj.load response.body
      {
        success: response.success?,
        message: d
      }
    rescue
      {
        success: response.success?,
        message: response.body
      }
    end

    ##
    # Load WHMCS version
    #
    # `{"result"=>"success", "whmcs"=>{"version"=>"8.2.0", "canonicalversion"=>"8.2.0-release.1"}}`
    #
    # @return Gem::Version
    def whmcs_version
      Gem::Version.new Oj.load(Whmcs::Base.new.remote('WhmcsDetails').body)['whmcs']['version']
    rescue
      Gem::Version.new '0.0'
    end

  end

end
