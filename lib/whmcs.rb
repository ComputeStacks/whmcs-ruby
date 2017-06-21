require 'cgi'
require 'json'
require 'yaml'
require 'securerandom'
require 'httparty'
require 'php_serialization'
require 'logger'

require 'whmcs/client'
require 'whmcs/errors'
require 'whmcs/invoice'
require 'whmcs/invoice_item'
require 'whmcs/order'
require 'whmcs/sso'
require 'whmcs/user'
require 'whmcs/subscription'
require 'whmcs/version'

module Whmcs
  ## Configuration defaults
  # enable_sso: [true|false]
  #
  @config = {
              order_redirect: true,
              endpoint: nil,
              api_key: nil,
              api_secret: nil,
              shared_secret: nil,
              legacy_login: false,
              enable_sso: true,
              default_payment_method: 'stripe',
              email_invoice: true,
              email_order: true,
              order_invoice: true.
              access_key: nil         
            }

  @valid_config_keys = @config.keys

  class << self

    attr_writer :logger

    def logger
      @logger ||= Logger.new($stdout).tap { |log| log.progname = 'WHMCS' }
    end

    # Configure through hash
    def configure(opts = {})
      opts.each {|k,v| @config[k.to_sym] = v if @valid_config_keys.include? k.to_sym}
    end

    # Configure through yaml file
    def configure_with(path_to_yaml_file)
      begin
        config = YAML::load(IO.read(path_to_yaml_file))
      rescue Errno::ENOENT
        log(:warning, "YAML configuration file couldn't be found. Using defaults."); return
      rescue Psych::SyntaxError
        log(:warning, "YAML configuration file contains invalid syntax. Using defaults."); return
      end
      configure(config)
    end

    def config
      @config
    end
  end  

end