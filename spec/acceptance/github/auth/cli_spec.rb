require 'spec_helper'
require 'support/mock_github_server'
require 'github/auth'

describe Github::Auth::CLI do
  with_mock_github_server do |mock_server_hostname, mock_keys|
    let(:hostname) { mock_server_hostname }
    let(:keys_file) { Tempfile.new 'authorized_keys' }
    let(:keys) { mock_keys }

    after { keys_file.unlink }

    def cli(args = [])
      described_class.start \
        args + [
          "--path=#{keys_file.path}",
          "--host=#{hostname}"
        ]
    end

    it 'adds and removes keys from the keys file' do
      Mute::IO.capture_stdout do
        cli %w(add --users=chrishunt)
      end

      keys_file.read.tap do |keys_file_content|
        keys.each { |key| expect(keys_file_content).to include key.to_s }
      end

      Mute::IO.capture_stdout do
        cli %w(remove --users=chrishunt)
      end

      expect(keys_file.read).to be_empty

      keys_file.unlink
    end

    it 'lists users from the keys file' do
      Mute::IO.capture_stdout do
        cli %w(add --users=chrishunt)
      end

      output = Mute::IO.capture_stdout do
        cli %w(list)
      end

      expect(output).to include('chrishunt')
    end

    it 'supports ssh commands' do
      Mute::IO.capture_stdout do
        cli %w(add --users=chrishunt) << '--command=tmux attach'
      end

      expect(keys_file.read).to include 'command="tmux attach"'

      keys_file.rewind

      Mute::IO.capture_stdout do
        cli %w(remove --users=chrishunt)
      end

      expect(keys_file.read.strip).to be_empty
    end

    it 'prints version information' do
      output = Mute::IO.capture_stdout do
        cli %w(version)
      end

      expect(output).to include Github::Auth::VERSION
    end
  end
end
