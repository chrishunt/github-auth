require 'spec_helper'
require 'support/mock_github_server'
require 'github/auth'

describe Github::Auth::KeysClient do
  it 'fetches all keys for the given github user' do
    with_mock_github_server do |hostname, keys|
      client = described_class.new(
        username: 'chrishunt',
        hostname: hostname
      )

      expect(client.keys).to eq keys
    end
  end
end
