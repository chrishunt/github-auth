require 'cgi'
require 'json'
require 'faraday'

module GitHub::Auth
  # Client for fetching public SSH keys using the GitHub API
  class KeysClient
    attr_reader :username, :hostname

    UsernameRequiredError = Class.new StandardError
    GitHubUnavailableError = Class.new StandardError
    GitHubUserDoesNotExistError = Class.new StandardError

    DEFAULT_HOSTNAME = 'https://api.github.com'
    USER_AGENT = "github_auth-#{VERSION}"

    DEFAULT_OPTIONS = {
      username: nil,
      hostname: DEFAULT_HOSTNAME
    }

    def initialize(options = {})
      options = DEFAULT_OPTIONS.merge options
      raise UsernameRequiredError unless options.fetch :username

      @username = CGI.escape(options.fetch :username)
      @hostname = options.fetch :hostname
    end

    def keys
      @keys ||= Array(github_response).map do |entry|
        GitHub::Auth::Key.new username, entry.fetch('key')
      end
    end

    private

    def github_response
      response = http_client.get \
        "#{hostname}/users/#{username}/keys", headers: headers

      raise GitHubUserDoesNotExistError if response.status == 404

      JSON.parse response.body
    rescue Faraday::Error => e
      raise GitHubUnavailableError, e
    end

    def http_client
      Faraday
    end

    def headers
      { 'User-Agent' => USER_AGENT }
    end
  end
end
