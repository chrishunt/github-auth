require 'tempfile'
require 'spec_helper'
require 'github/auth'

describe Github::Auth::KeysFile do
  it 'writes and deletes keys from the keys file' do
    tempfile  = Tempfile.new 'authorized_keys'
    keys_file = described_class.new path: tempfile.path

    keys = [
      Github::Auth::Key.new('chris', 'abc123'),
      Github::Auth::Key.new('doug', 'def456')
    ]

    keys_file.write! keys
    expect(tempfile.read).to include keys.join("\n")

    tempfile.rewind

    keys_file.delete! keys.first
    tempfile.read.tap do |tempfile_content|
      expect(tempfile_content).to_not include keys.first.to_s
      expect(tempfile_content).to include keys.last.to_s
    end

    tempfile.rewind

    keys_file.delete! keys.last
    expect(tempfile.read).to be_empty
  end
end
