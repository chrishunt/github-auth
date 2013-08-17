require 'optparse'
module Github::Auth
  # Command Line Interface for parsing and executing commands
  class CLI
    attr_reader :command, :usernames

    COMMANDS = %w(add remove)

    def initialize(argv)
      @opts = {}
      OptionParser.new do |opts|
        opts.on('-u', '--user=USER', 'username to install') do |user|
          @opts[:path] = "~#{user}/.ssh/authorized_keys"
        end
        opts.on('-p', '--path=PATH', 'path to key file') do |path|
          @opts[:path] = path
        end
        opts.on('-v', '--version', 'version of github-auth') do
          @opts[:version] = true
        end
      end.parse!(argv)
      @command   = argv.shift
      @usernames = argv
    end

    def execute
      if COMMANDS.include?(command) && !usernames.empty?
        set_path(@opts[:path]) if @opts[:path]
        send command
      elsif @opts[:version]
        print_version
      else
        print_usage
      end
    end

    private

    def add
      on_keys_file :write!,
        "Adding #{keys.count} key(s) to '#{keys_file.path}'"
    end

    def remove
      on_keys_file :delete!,
        "Removing #{keys.count} key(s) from '#{keys_file.path}'"
    end

    def on_keys_file(action, message)
      puts message
      rescue_keys_file_errors { keys_file.send action, keys }
    end

    def rescue_keys_file_errors
      yield
    rescue KeysFile::PermissionDeniedError
      print_permission_denied
    rescue KeysFile::FileDoesNotExistError
      print_file_does_not_exist
    end

    def print_usage
      puts "usage: gh-auth [--version] [#{COMMANDS.join '|'}] <username>"
    end

    def print_version
      puts "gh-auth version #{Github::Auth::VERSION}"
    end

    def print_permission_denied
      puts 'Permission denied!'
      puts
      puts "Make sure you have write permissions for '#{keys_file.path}'"
    end

    def print_file_does_not_exist
      puts "Keys file does not exist!"
      puts
      puts "Create one now and try again:"
      puts
      puts "  $ touch #{keys_file.path}"
    end

    def print_github_user_does_not_exist(username)
      puts "Github user '#{username}' does not exist"
    end

    def print_github_unavailable
      puts "Github appears to be unavailable :("
      puts
      puts "https://status.github.com"
    end

    def keys
      @keys ||= usernames.map { |username| keys_for username }.flatten.compact
    end

    def keys_for(username)
      Github::Auth::KeysClient.new(
        hostname: github_hostname,
        username: username
      ).keys
    rescue Github::Auth::KeysClient::GithubUserDoesNotExistError
      print_github_user_does_not_exist username
    rescue Github::Auth::KeysClient::GithubUnavailableError
      print_github_unavailable
    end

    def keys_file
      Github::Auth::KeysFile.new path: keys_file_path
    end

    def set_path(path)
      @path = path
    end

    def keys_file_path
      @path || Github::Auth::KeysFile::DEFAULT_PATH
    end

    def github_hostname
      Github::Auth::KeysClient::DEFAULT_HOSTNAME
    end
  end
end
