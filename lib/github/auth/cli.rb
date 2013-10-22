module Github::Auth
  # Command Line Interface for parsing and executing commands
  class CLI
    attr_reader :command, :usernames

    COMMANDS = %w(add remove list)

    def initialize(argv)
      @command   = argv.shift
      @usernames = argv
    end

    def execute
      if COMMANDS.include?(command)
        send command
      elsif command == '--version'
        puts "gh-auth version #{Github::Auth::VERSION}"
      else
        print_usage
      end
    end

    private

    def add
      if usernames.empty?
        print_usage
        return
      end

      on_keys_file :write!,
        "Adding #{keys.count} key(s) to '#{keys_file.path}'"
    end

    def remove
      if usernames.empty?
        print_usage
        return
      end

      on_keys_file :delete!,
        "Removing #{keys.count} key(s) from '#{keys_file.path}'"
    end

    def list
      puts "Added users: #{keys_file.github_users.join(', ')}"
    end

    def on_keys_file(action, message)
      puts message
      rescue_keys_file_errors { keys_file.send action, keys }
    end

    def rescue_keys_file_errors
      yield
    rescue KeysFile::PermissionDeniedError
      puts 'Permission denied!'
      puts
      puts "Make sure you have write permissions for '#{keys_file.path}'"
    rescue KeysFile::FileDoesNotExistError
      puts "Keys file does not exist!"
      puts
      puts "Create one now and try again:"
      puts
      puts "  $ touch #{keys_file.path}"
    end

    def print_usage
      puts "usage: gh-auth [--version] [#{COMMANDS.join '|'}] <username>"
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
      puts "Github user '#{username}' does not exist"
    rescue Github::Auth::KeysClient::GithubUnavailableError
      puts "Github appears to be unavailable :("
      puts
      puts "https://status.github.com"
    end

    def keys_file
      Github::Auth::KeysFile.new path: keys_file_path
    end

    def keys_file_path
      Github::Auth::KeysFile::DEFAULT_PATH
    end

    def github_hostname
      Github::Auth::KeysClient::DEFAULT_HOSTNAME
    end
  end
end
