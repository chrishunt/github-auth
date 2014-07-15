require 'faraday'
require 'sinatra/base'
require 'json'

require 'github/auth/key'

module GitHub::Auth
  class MockGitHubServer < Sinatra::Base
    KEYS = [
      GitHub::Auth::Key.new('chrishunt', 'abc123'),
      GitHub::Auth::Key.new('chrishunt', 'def456')
    ]

    set :port, 8001

    get '/' do
      'success'
    end

    get '/users/chrishunt/keys' do
      content_type :json

      [
        { 'id' => 123, 'key' => KEYS[0].key },
        { 'id' => 456, 'key' => KEYS[1].key }
      ].to_json
    end
  end
end

def with_mock_github_server
  hostname = "http://localhost:#{GitHub::Auth::MockGitHubServer.port}"
  Thread.new { GitHub::Auth::MockGitHubServer.run! }

  while true
    begin
      Faraday.get hostname
      break
    rescue Faraday::ConnectionFailed
      # Do nothing, try again
    end
  end

  yield hostname, GitHub::Auth::MockGitHubServer::KEYS
end
