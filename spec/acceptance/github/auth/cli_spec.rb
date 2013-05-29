require 'spec_helper'
require 'support/mock_github_server'
require 'github/auth'

describe Github::Auth::CLI do
  with_mock_github_server do |mock_server_hostname, mock_keys|
    let(:hostname) { mock_server_hostname }
    let(:keys_file) { Tempfile.new 'authorized_keys' }
    let(:keys) { mock_keys }

    after { keys_file.unlink }

    def cli(argv)
      described_class.new(argv).tap do |cli|
        cli.stub(
          github_hostname: hostname,
          keys_file_path: keys_file.path
        )
      end
    end

    it 'adds and removes keys from the keys file' do
      cli(%w(add chrishunt)).execute

      keys_file.read.tap do |keys_file_content|
        keys.each { |key| expect(keys_file_content).to include key.to_s }
      end

      cli(%w(remove chrishunt)).execute

      expect(keys_file.read).to be_empty

      keys_file.unlink
    end
  end
end
