require 'optparse'

module Github::Auth
  # Parses command line options
  class Options
    attr_reader :parser

    def initialize
      @parser = OptionParser.new do |opts|
        opts.banner = [
          'usage: gh-auth',
          '[--version]',
          '[--list]',
          '[--add|--remove]', '<username>',
          '[--command]', '<command>'
        ].join(' ')

        opts.separator ""
        opts.separator "options:"

        opts.on('--list', 'List all GitHub users added') do
          @command = 'list'
        end

        opts.on(
          '--add doug,sally', Array, 'Add GitHub users'
        ) do |usernames|
          raise OptionParser::MissingArgument if usernames.empty?
          @command = 'add'
          @usernames = usernames
        end

        opts.on(
          '--remove doug,sally', Array, 'Remove GitHub users'
        ) do |usernames|
          raise OptionParser::MissingArgument if usernames.empty?
          @command = 'remove'
          @usernames = usernames
        end

        opts.on(
          '--command "tmux attach"', String, 'Command to execute on login'
        ) do |command|
          keys_file_options.merge!(command: command)
        end

        opts.on_tail('--version', 'Show version') do
          @command = 'version'
        end

        opts.on_tail('-h', '--help', '--usage', 'Show this help message') do
          puts opts.help
          exit
        end
      end
    end

    def command
      @command ||= 'usage'
    end

    def usernames
      @usernames ||= []
    end

    def keys_file_options
      @keys_file_options ||= {}
    end

    def usage
      parser.help
    end

    def parse(args)
      parser.parse(args)
    ensure
      return self
    end
  end
end
