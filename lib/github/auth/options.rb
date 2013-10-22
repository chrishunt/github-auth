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
          '[--add|--remove]',
          '<username>'
        ].join(' ')

        opts.separator "\noptions:"

        opts.on(
          '--add doug,sally', Array,
          "GitHub user(s) you'd like to add"
        ) do |usernames|
          raise OptionParser::MissingArgument if usernames.empty?
          @command = 'add'
          @usernames = usernames
        end

        opts.on(
          '--remove doug,sally', Array,
          "GitHub user(s) you'd like to remove"
        ) do |usernames|
          raise OptionParser::MissingArgument if usernames.empty?
          @command = 'remove'
          @usernames = usernames
        end

        opts.on('--list', "List all GitHub users you've added") do
          @command = 'list'
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
