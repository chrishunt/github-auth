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
          '[--tmux]',
          '[--add|--remove]',
          '<username>'
        ].join(' ')

        opts.separator "\noptions:"

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

        opts.on('--list', 'List all GitHub users added') do
          @command = 'list'
        end

        opts.on('--tmux', 'Attach user to tmux session') do
          keys_file.merge!(tmux: true)
        end

        opts.on('--version', 'Show version') do
          @command = 'version'
        end
      end
    end

    def command
      @command ||= 'usage'
    end

    def usernames
      @usernames ||= []
    end

    def keys_file
      @keys_file ||= {}
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
