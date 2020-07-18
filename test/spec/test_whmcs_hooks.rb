require_relative '../helper'

describe Whmcs::Hooks do

  describe "running hooks" do

    before do
      Whmcs.configure(
        endpoint: ENV['WHMCS_ENDPOINT'],
        api_key: ENV['WHMCS_API_KEY'],
        api_secret: ENV['WHMCS_API_SECRET'],
        due_date: '15',
        invoice_on: 'nextcron'
      )
    end

    it 'can run user_created hook' do
      VCR.use_cassette("user_created_hook") do
        fake_user = TestWhmcsMocks::User.new
        fake_user.labels = {
          'cpanel' => {
            'mycpanelserver.net' => 'jane.doe3-10@demo.computestacks.net'
          }
        }
        assert Whmcs::Hooks.method_defined? :user_created

        hook = Whmcs::Hooks.new
        assert hook.user_created(fake_user)
      end
    end

    it 'can run user_created hook on a user without labels' do
      VCR.use_cassette("user_created_hook") do
        fake_user = TestWhmcsMocks::User.new
        assert Whmcs::Hooks.method_defined? :user_created

        hook = Whmcs::Hooks.new
        assert hook.user_created(fake_user)
      end
    end

    it 'can process aggregated usage' do
      data = YAML.load File.open('test/fixtures/aggregated_usage.yml').read
      assert Whmcs::Hooks.method_defined? :process_usage
      VCR.use_cassette("create_billable_items") do
        hook = Whmcs::Hooks.new
        success = hook.process_usage(data)
        assert success
        assert_empty hook.errors
      end
    end

    it 'can process update_user' do
      VCR.use_cassette("user_update_hook") do
        fake_user = TestWhmcsMocks::User.new
        fake_user.email = 'fakeuseremail@demo.computestacks.net'
        fake_user.labels = {
          'whmcs' => {
            'service_id' => 10
          }
        }
        assert Whmcs::Hooks.method_defined? :user_updated
        hook = Whmcs::Hooks.new
        success = hook.user_updated fake_user
        assert success
        assert_empty hook.errors

        # Now, put the original username back
        check_service = Whmcs::Service.find(10)
        check_service.username = "jane.doe3-10@demo.computestacks.net"
        assert check_service.save
      end
    end

  end

end
