require 'spec_helper'
require 'tempfile'
require 'github/auth/key'
require 'github/auth/keys_file'

describe Github::Auth::KeysFile do
  subject { described_class.new(options) }

  let(:keys_file) { Tempfile.new 'authorized_keys' }
  let(:options) {{ path: path }}
  let(:path) { keys_file.path }

  after { keys_file.unlink } # clean up, delete tempfile

  describe '#initialize' do
    context 'without a path' do
      let(:path) { nil }

      it 'has a default path' do
        expect(subject.path).to_not be_nil
      end
    end

    context 'with a custom path' do
      let(:path) { '/foo/bar/baz' }

      it 'saves the custom path' do
        expect(subject.path).to eq path
      end
    end

    context 'with an unexpanded path' do
      let(:path) { '~/my/home/dir' }

      it 'expands the path' do
        expect(subject.path).to_not include '~'
      end
    end
  end

  describe '#write!' do
    shared_examples_for 'a successful key addition' do
      it 'writes the key and github url to the keys file' do
        subject.write! keys

        keys_file.read.tap do |keys_file_content|
          keys.each do |key|
            expect(keys_file_content).to include "#{key.key} #{key.url}"
          end
        end
      end

      it 'does not include a blank before the first key' do
        subject.write! keys

        expect(keys_file.read).to_not start_with("\n")
      end

      it 'includes a newline after the last key' do
        subject.write! keys

        expect(keys_file.read).to end_with("\n")
      end
    end

    context 'with many keys' do
      let(:keys) {[
        Github::Auth::Key.new('chris', 'abc123'),
        Github::Auth::Key.new('chris', 'def456'),
        Github::Auth::Key.new('doug', 'ghi789')
      ]}

      it_should_behave_like 'a successful key addition'
    end

    context 'with a single key' do
      let(:keys) {[ Github::Auth::Key.new('chris', 'abc123') ]}

      it_should_behave_like 'a successful key addition'
    end

    context 'with an ssh command' do
      let(:options) {{ path: path, command: 'tmux attach' }}
      let(:keys) {[ Github::Auth::Key.new('chris', 'abc123') ]}

      it_should_behave_like 'a successful key addition'

      it 'prefixes the key with the ssh command' do
        subject.write! keys

        expect(keys_file.read).to include 'command="tmux attach"'
      end
    end

    context 'with ssh options' do
      let(:options) {{ path: path, ssh_options: ['no-way', 'no-how'] }}
      let(:keys) {[ Github::Auth::Key.new('chris', 'abc123') ]}

      it_should_behave_like 'a successful key addition'

      it 'prefixes the key with the comma-separated ssh options' do
        subject.write! keys

        expect(keys_file.read).to include 'no-way,no-how'
      end
    end

    context 'with existing keys in the keys file' do
      let(:existing_keys) { %w(abc123 def456 ghi789) }
      let(:keys) {[ Github::Auth::Key.new('chris', 'jkl012') ]}

      before do
        keys_file.write existing_keys.join("\n")
        keys_file.write "\n"
        keys_file.rewind
      end

      it_should_behave_like 'a successful key addition'

      it 'preserves the existing keys' do
        subject.write! keys

        keys_file.read.tap do |keys_file_content|
          existing_keys.each do |key|
            expect(keys_file_content).to include "#{key}\n"
          end
        end
      end

      it 'does not write duplicate keys into the keys file' do
        subject.write! Github::Auth::Key.new('chris', existing_keys.first)

        expect(keys_file.readlines.count).to eq existing_keys.count
      end
    end

    context 'when the keys file is readonly' do
      before { File.chmod(0400, keys_file) }

      it 'raises PermissionDeniedError' do
        expect {
          subject.write! Github::Auth::Key.new('chris', 'abc123')
        }.to raise_error Github::Auth::KeysFile::PermissionDeniedError
      end
    end

    context 'when the keys file does not exist' do
      let(:path) { 'not/a/real/file/path' }

      it 'raises FileDoesNotExistError' do
        expect {
          subject.write! %w(abc123 def456)
        }.to raise_error Github::Auth::KeysFile::FileDoesNotExistError
      end
    end
  end

  describe '#delete!' do
    let(:keys) {[
      Github::Auth::Key.new('chris', 'abc123'),
      Github::Auth::Key.new('chris', 'def456'),
      Github::Auth::Key.new('doug', 'ghi789')
    ]}

    before do
      keys_file.write keys.join("\n")
      keys_file.write "\n"
      keys_file.rewind
    end

    shared_examples_for 'a successful key removal' do
      it 'removes the key from the keys file' do
        subject.delete! key

        expect(keys_file.read).to_not include key.to_s
      end

      it 'does not remove the other keys from the keys file' do
        subject.delete! key

        keys_file.read.tap do |keys_file_content|
          keys.reject { |other_key| other_key == key }.each do |key|
            expect(keys_file_content).to include key.to_s
          end
        end
      end

      it 'includes a newline after the last key' do
        subject.delete! key

        expect(keys_file.read).to end_with("\n")
      end
    end

    context 'when the key is at the beginning of the keys file' do
      let(:key) { keys.first }

      it_should_behave_like 'a successful key removal'
    end

    context 'when the key is in the middle of the keys file' do
      let(:key) { keys[1] }

      it_should_behave_like 'a successful key removal'
    end

    context 'when the key is at the end of the keys file' do
      let(:key) { keys.last }

      it_should_behave_like 'a successful key removal'
    end

    context 'when the keys file does not have the key' do
      let(:key) { Github::Auth::Key.new('sallie', 'not-in-the-keys-file') }

      it 'does not modify the keys file' do
        keys_file.read.tap do |original_keys_file_content|
          keys_file.rewind

          subject.delete! key

          expect(keys_file.read).to eq original_keys_file_content
        end
      end
    end
  end

  describe '#github_users' do
    let(:keys) {[
      Github::Auth::Key.new('jay',   'abc123'),
      Github::Auth::Key.new('chris', 'def456'),
      Github::Auth::Key.new('chris', 'ghi789'),
    ]}

    before do
      keys_file.write keys.join("\n")
      keys_file.write "\n"
      keys_file.rewind
    end

    it 'returns a uniq, ordered list of github users' do
      expect(subject.github_users).to eq(%w(chris jay))
    end
  end
end
