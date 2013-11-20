require 'thor'

module Github::Auth
  # Command Line Interface for parsing and executing commands
  class CLI < Thor
    class_option :host, type: :string
    class_option :path, type: :string

    option :users, type: :array, required: true
    option :command, type: :string
    option :ssh_options, type: :array
    option :no_forwarding, type: :boolean
    desc 'add', 'Add GitHub users to authorized keys'
    long_desc <<-LONGDESC
        `gh-auth add` is used to add one or more GitHub user's public SSH keys
        to ~/.ssh/authorized_keys. All keys stored on github.com for that
        user will be added.

        > $ gh-auth add --users=chrishunt zachmargolis
        \x5> Adding 6 key(s) to '/Users/chris/.ssh/authorized_keys'

        By default, users will be granted normal shell access. If you'd like to
        specify an ssh command that should execute when the user connects, use
        the `--command` option.

        > $ gh-auth add --users=chrishunt --command="tmux attach"

        You may also provide options for the key entry, such as preventing
        port forwarding. To do this, include the `--ssh-options` option.

        > $ gh-auth add --users=chrishunt --ssh-options=no-port-forwarding

        To disable all forwarding for their connection, use the
        `--no-forwarding` option.

        > $ gh-auth add --users=chrishunt --no-forwarding
    LONGDESC
    def add
      on_keys_file :write!,
        "Adding #{keys.count} key(s) to '#{keys_file.path}'",
        { command: options[:command],
          ssh_options: options[:ssh_options],
          no_forwarding: options[:no_forwarding] }
    end

    option :users, type: :array, required: true
    desc 'remove', 'Remove GitHub users from authorized keys'
    long_desc <<-LONGDESC
        `gh-auth remove` is used to remove one or more GitHub user's public SSH
        keys from ~/.ssh/authorized_keys. All keys stored on github.com for
        that user will be removed.

        > $ gh-auth remove --users=chrishunt zachmargolis
        \x5> Removing 6 key(s) to '/Users/chris/.ssh/authorized_keys'
    LONGDESC
    def remove
      on_keys_file :delete!,
        "Removing #{keys.count} key(s) from '#{keys_file.path}'"
    end

    desc 'list', 'List all GitHub users already added to authorized keys'
    long_desc <<-LONGDESC
        `gh-auth list` will list all GitHub users that have been added to
        ~/.ssh/authorized_keys by `gh-auth`.

        > $ gh-auth list
        \x5> chrishunt, zachmargolis
    LONGDESC
    def list
      rescue_keys_file_errors { puts keys_file.github_users.join(' ') }
    end

    desc 'version', 'Show gh-auth version'
    def version
      puts Github::Auth::VERSION
    end

    private

    def keys
      @keys ||= begin
        Array(options[:users]).map { |user| keys_for user }.flatten.compact
      end
    end

    def on_keys_file(action, message, options = {})
      puts message
      rescue_keys_file_errors { keys_file(options).send action, keys }
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

    def keys_file(options = {})
      Github::Auth::KeysFile.new \
        options.merge path: keys_file_path
    end

    def keys_file_path
      options[:path] || Github::Auth::KeysFile::DEFAULT_PATH
    end

    def github_hostname
      options[:host] || Github::Auth::KeysClient::DEFAULT_HOSTNAME
    end
  end
end
