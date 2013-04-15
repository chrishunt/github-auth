require 'httparty'

module Github::Auth
  class KeysClient
    attr_reader :username, :hostname

    UsernameRequiredException  = Class.new StandardError
    GithubUnavailableException = Class.new StandardError
    GithubUserDoesNotExistError = Class.new StandardError

    DEFAULT_OPTIONS = {
      username: nil,
      hostname: 'https://api.github.com'
    }

    def initialize(options = {})
      options = DEFAULT_OPTIONS.merge options
      raise UsernameRequiredException unless options.fetch(:username)

      @username = options.fetch :username
      @hostname = options.fetch :hostname
    end

    def keys
      @keys ||= github_response.map { |entry| entry.fetch 'key' }
    end

    private

    def github_response
      response = http_client.get "#{hostname}/users/#{username}/keys"
        raise GithubUserDoesNotExistError if response.code == 404
      response.parsed_response
    rescue SocketError, Errno::ECONNREFUSED => e
      raise GithubUnavailableException.new e
    end

    def http_client
      HTTParty
    end
  end
end
