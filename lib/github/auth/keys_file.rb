module Github::Auth
  # Write and delete keys from the authorized_keys file
  class KeysFile
    attr_reader :path, :command, :lockdown

    PermissionDeniedError = Class.new StandardError
    FileDoesNotExistError = Class.new StandardError

    DEFAULT_PATH = '~/.ssh/authorized_keys'

    def initialize(options = {})
      @path = File.expand_path(options[:path] || DEFAULT_PATH)
      @command  = options[:command]
      @lockdown = options.fetch(:lockdown){ false }
    end

    def write!(keys)
      Array(keys).each do |key|
        unless keys_file_content.include? key.key
          append_keys_file do |keys_file|
            unless keys_file_content.empty? || keys_file_content.end_with?("\n")
              keys_file.write "\n"
            end
            keys_file.write key_line(key)
          end
        end
      end
    end

    def delete!(keys)
      new_content = keys_file_content_without keys

      write_keys_file { |keys_file| keys_file.write new_content }
    end

    def github_users
      # http://rubular.com/r/zXCkewmm0i
      regex = %r{github\.com/(\S+)}
      keys_file_content.scan(regex).flatten.uniq.sort
    end

    private

    def append_keys_file(&block)
      with_keys_file 'a', block
    end

    def write_keys_file(&block)
      with_keys_file 'w', block
    end

    def keys_file_content
      with_keys_file 'r', Proc.new { |keys_file| keys_file.read }
    end

    def with_keys_file(mode, block)
      File.open(path, mode) { |keys_file| block.call keys_file }
    rescue Errno::EACCES => e
      raise PermissionDeniedError, e
    rescue Errno::ENOENT => e
      raise FileDoesNotExistError, e
    end

    def keys_file_content_without(keys)
      keys_file_content.tap do |content|
        Array(keys).each do |key|
          content.gsub! /(.*)?#{Regexp.escape key.key}(.*)?$\n?/, ''
        end

        content << "\n" unless content.empty? || content.end_with?("\n")
      end
    end

    def key_line_prefixes
      prefixes = []
      prefixes << 'no-port-forwarding,no-X11-forwarding,no-agent-forwarding' if lockdown
      prefixes << %Q{command="#{command}"} if command
      prefixes.join(',')
    end

    def key_line(key)
      line = []
      line << key_line_prefixes unless key_line_prefixes.empty?
      line << "#{key}\n"
      line.join(' ')
    end
  end
end
