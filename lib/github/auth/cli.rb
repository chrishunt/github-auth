module Github::Auth
  # Command Line Interface for parsing and executing commands
  class CLI
    attr_reader :options

    def execute(args)
      @options = Options.new.parse(args)
      send options.command
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

    def list
      puts "Added users: #{keys_file.github_users.join(', ')}"
    end

    def version
      puts Github::Auth::VERSION
    end

    def usage
      puts options.usage
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

    def keys
      @keys ||= options.usernames.map { |user| keys_for user }.flatten.compact
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
      Github::Auth::KeysFile.new keys_file_options
    end

    def keys_file_options
      options.keys_file_options.merge path: keys_file_path
    end

    def keys_file_path
      Github::Auth::KeysFile::DEFAULT_PATH
    end

    def github_hostname
      Github::Auth::KeysClient::DEFAULT_HOSTNAME
    end
  end
end
