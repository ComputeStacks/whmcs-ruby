require 'cgi'
require 'json'
require 'yaml'
require 'securerandom'
require 'httparty'
require 'php_serialization'

require 'whmcs/client'
require 'whmcs/errors'
require 'whmcs/invoice'
require 'whmcs/invoice_item'
require 'whmcs/order'
require 'whmcs/sso'
require 'whmcs/user'
require 'whmcs/version'

module Whmcs
  ## Configuration defaults
  # enable_sso: [true|false]
  #
  @config = {
              endpoint: nil,
              enable_sso: true,
              default_payment_method: 'stripe',
              container_product_id: 1,
              email_invoice: true,
              email_order: true,
              order_invoice: true,
              auth: {
                api_key: nil,
                api_secret: nil,
                shared_secret: nil
              }
            }

  @valid_config_keys = @config.keys

  # Configure through hash
  def self.configure(opts = {})
    opts.each {|k,v| @config[k.to_sym] = v if @valid_config_keys.include? k.to_sym}
  end

  # Configure through yaml file
  def self.configure_with(path_to_yaml_file)
    begin
      config = YAML::load(IO.read(path_to_yaml_file))
    rescue Errno::ENOENT
      log(:warning, "YAML configuration file couldn't be found. Using defaults."); return
    rescue Psych::SyntaxError
      log(:warning, "YAML configuration file contains invalid syntax. Using defaults."); return
    end
    configure(config)
  end

  def self.config
    @config
  end

end