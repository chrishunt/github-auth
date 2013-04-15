module Github::Auth
  class KeysFile
    attr_reader :path

    KeysRequiredException = Class.new StandardError

    DEFAULT_PATH = '~/.ssh/authorized_keys'

    def initialize(options = {})
      @path = options[:path] || DEFAULT_PATH
    end

    def write!(keys)
      append_file do |keys_file|
        Array(keys).each do |key|
          keys_file.write "\n#{key}" unless keys_file_content.include? key
        end
      end
    end

    def delete!(keys)
      content = keys_file_content_without keys
      write_file { |keys_file| keys_file.write content }
    end

    private

    def append_file(&block)
      with_file 'a', block
    end

    def write_file(&block)
      with_file 'w', block
    end

    def with_file(mode, block)
      File.open(path, mode) { |keys_file| block.call keys_file }
    end

    def keys_file_content
      File.read path
    end

    def keys_file_content_without(keys)
      keys_file_content.tap do |content|
        Array(keys).each { |key| content.gsub! /#{key}.*$/, '' }
      end
    end
  end
end
