require_relative '../helper'

describe Whmcs::Base do

  describe "connecting to whmcs" do

    before do
      Whmcs.configure(
        endpoint: '',
        api_key: '',
        api_secret: '',
        access_key: '',
        due_date: '1'
      )
    end

    it 'can validate invalid params' do
      assert_raises Whmcs::Error do
        Whmcs::Base.new.remote('foo')
      end
    end

  end

end
