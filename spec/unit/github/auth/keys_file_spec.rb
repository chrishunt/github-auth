require 'spec_helper'
require 'tempfile'
require 'github/auth/keys_file'

describe Github::Auth::KeysFile do
  subject { described_class.new path: path }

  let(:keys) { %w(abc123 def456) }
  let(:keys_file) { Tempfile.new 'authorized_keys' }
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
    it 'writes each key to the keys file' do
      subject.write! keys
      file_content = keys_file.read
      keys.each { |key| expect(file_content).to include key }
    end

    context 'with a single key' do
      let(:key) { 'abc123' }

      it 'writes the single key to the keys file' do
        subject.write! key
        expect(keys_file.read).to include key
      end
    end

    context 'with existing keys in the keys file' do
      let(:existing_keys) { %w(ghi789 jkl123) }

      before do
        keys_file.write existing_keys.join("\n")
        keys_file.rewind
      end

      it 'preserves the existing keys' do
        subject.write! keys
        file_lines = keys_file.readlines
        existing_keys.each { |key| expect(file_lines).to include "#{key}\n" }
      end

      it 'does not write duplicate keys into the keys file' do
        subject.write! existing_keys.first
        expect(keys_file.readlines.count).to eq existing_keys.count
      end
    end

    context 'when the keys file is readonly' do
      before { File.chmod(0400, keys_file) }

      it 'raises PermissionDeniedError' do
        expect {
          subject.write! keys
        }.to raise_error Github::Auth::KeysFile::PermissionDeniedError
      end
    end

    context 'when the keys file does not exist' do
      let(:path) { 'not/a/real/file/path' }

      it 'raises FileDoesNotExistError' do
        expect {
          subject.write! keys
        }.to raise_error Github::Auth::KeysFile::FileDoesNotExistError
      end
    end
  end

  describe '#delete!' do
    before do
      keys_file.write keys.join("\n")
      keys_file.rewind
    end

    context 'when the keys file has the key' do
      let(:key) { keys[0] }
      let(:other_key) { keys[1] }

      it 'removes the key from the keys file' do
        subject.delete! key
        expect(keys_file.read).to_not include key
      end

      it 'does not remove the other key from the keys file' do
        subject.delete! key
        expect(keys_file.read).to include other_key
      end

      it 'does not leave blank lines' do
        subject.delete! [key, other_key]
        blank_lines = keys_file.readlines.select { |line| line =~ /^$\n/ }

        expect(blank_lines).to be_empty
      end
    end

    context 'when the keys file does not have the key' do
      let(:key) { 'not-in-the-keys-file' }

      it 'does not modify the keys file' do
        original_keys_file = keys_file.read
        keys_file.rewind

        subject.delete! key

        expect(keys_file.read).to eq original_keys_file
      end
    end
  end
end
