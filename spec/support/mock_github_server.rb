require 'httparty'
require 'sinatra/base'
require 'json'

module Github::Auth
  class MockGithubServer < Sinatra::Base
    KEYS = %w(abc234 def456)

    set :port, 8001

    get '/' do
      'success'
    end

    get '/users/chrishunt/keys' do
      content_type :json

      [
        { 'id' => 123, 'key' => KEYS[0] },
        { 'id' => 456, 'key' => KEYS[1] }
      ].to_json
    end
  end
end

def with_mock_github_server
  hostname = "http://localhost:#{Github::Auth::MockGithubServer.port}"
  Thread.new { Github::Auth::MockGithubServer.run! }

  while true
    begin
      HTTParty.get(hostname)
      break
    rescue Errno::ECONNREFUSED
      sleep 0.5
    end
  end

  yield hostname, Github::Auth::MockGithubServer::KEYS
end
