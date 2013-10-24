require 'spec_helper'
require 'support/capture_stdout'
require 'support/mock_github_server'
require 'github/auth'

describe Github::Auth::CLI do
  with_mock_github_server do |mock_server_hostname, mock_keys|
    let(:hostname) { mock_server_hostname }
    let(:keys_file) { Tempfile.new 'authorized_keys' }
    let(:keys) { mock_keys }

    after { keys_file.unlink }

    def cli
      described_class.new.tap do |cli|
        cli.stub(
          github_hostname: hostname,
          keys_file_path: keys_file.path
        )
      end
    end

    it 'adds and removes keys from the keys file' do
      cli.execute %w(--add chrishunt)

      keys_file.read.tap do |keys_file_content|
        keys.each { |key| expect(keys_file_content).to include key.to_s }
      end

      cli.execute %w(--remove chrishunt)

      expect(keys_file.read).to be_empty

      keys_file.unlink
    end

    it 'lists users from the keys file' do
      cli.execute %w(--add chrishunt)

      output = capture_stdout do
        cli.execute %w(--list)
      end

      expect(output).to include('chrishunt')
    end

    it 'prints version information' do
      output = capture_stdout do
        cli.execute %w(--version)
      end

      expect(output).to include Github::Auth::VERSION
    end

    it 'can automatically attach users to a tmux session' do
      cli.execute %w(--tmux --add chrishunt)

      expect(keys_file.read).to include Github::Auth::KeysFile::TMUX_COMMAND

      keys_file.rewind
      cli.execute %w(--remove chrishunt)

      expect(keys_file.read.strip).to be_empty
    end

    it 'prints usage for invalid arguments' do
      [[], %w(invalid), %w(--add)].each do |invalid_arguments|
        expect(
          capture_stdout { cli.execute invalid_arguments }
        ).to include 'usage: gh-auth'
      end
    end
  end
end
