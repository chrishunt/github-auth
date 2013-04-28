module Github::Auth
  # Write and delete keys from the authorized_keys file
  class KeysFile
    attr_reader :path

    PermissionDeniedError = Class.new StandardError
    FileDoesNotExistError = Class.new StandardError

    DEFAULT_PATH = '~/.ssh/authorized_keys'

    def initialize(options = {})
      @path = File.expand_path(options[:path] || DEFAULT_PATH)
    end

    def write!(keys)
      append_keys_file do |keys_file|
        Array(keys).each do |key|
          keys_file.write "\n#{key}" unless keys_file_content.include? key
        end
      end
    end

    def delete!(keys)
      new_content = keys_file_content_without keys

      write_keys_file { |keys_file| keys_file.write new_content }
    end

    private

    def append_keys_file(&block)
      with_keys_file 'a', block
    end

    def write_keys_file(&block)
      with_keys_file 'w', block
    end

    def with_keys_file(mode, block)
      File.open(path, mode) { |keys_file| block.call keys_file }
    rescue Errno::EACCES => e
      raise PermissionDeniedError.new e
    rescue Errno::ENOENT => e
      raise FileDoesNotExistError.new e
    end

    def keys_file_content
      File.read path
    end

    def keys_file_content_without(keys)
      keys_file_content.tap do |content|
        Array(keys).each { |k| content.gsub! /#{Regexp.escape(k)}( .*)?/, '' }
        content.strip!
      end
    end
  end
end
