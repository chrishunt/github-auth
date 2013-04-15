require 'spec_helper'
require 'tempfile'
require 'github/auth/keys_file'

describe Github::Auth::KeysFile do
  subject { described_class.new path: path }

  let(:path) { nil }

  describe '#initialize' do
    it 'has a default path' do
      expect(subject.path).to_not be_nil
    end

    context 'with a custom path' do
      let(:path) { '/foo/bar/baz' }

      it 'saves the custom path' do
        expect(subject.path).to eq path
      end
    end
  end

  describe '#write!' do
    let(:keys) { %w(abc123 def456) }
    let(:path) { keys_file.path }
    let(:keys_file) { Tempfile.new 'authorized_keys' }

    after { keys_file.unlink } # clean up, delete tempfile

    it 'writes the given keys to the keys file' do
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

    context 'with keys already in the keys file' do
      let(:existing_keys) { %w(ghi789 jkl123) }

      before do
        keys_file.write existing_keys.join("\n")
        keys_file.rewind
      end

      it 'preserves the keys' do
        subject.write! keys
        file_lines = keys_file.readlines
        existing_keys.each { |key| expect(file_lines).to include "#{key}\n" }
      end

      it 'does not put a duplicate key into the keys file' do
        subject.write! existing_keys.first
        expect(keys_file.readlines.count).to eq existing_keys.count
      end
    end
  end

  describe '#delete!' do
    let(:keys) { %w(abc123 def456) }
    let(:path) { keys_file.path }
    let(:keys_file) { Tempfile.new 'authorized_keys' }

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

      it 'does not remove other keys' do
        subject.delete! key
        expect(keys_file.read).to include other_key
      end
    end

    context 'when the keys file does not have the key' do
      let(:key) { 'notinthefile' }

      it 'does not modify the file' do
        original_content = keys_file.read
        keys_file.rewind

        subject.delete! key

        expect(keys_file.read).to eq original_content
      end
    end
  end
end
