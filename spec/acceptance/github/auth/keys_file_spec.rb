require 'tempfile'
require 'spec_helper'
require 'github/auth'

describe Github::Auth::KeysFile do
  it 'writes and deletes keys from the keys file' do
    tempfile  = Tempfile.new 'authorized_keys'
    keys_file = described_class.new path: tempfile.path
    keys      = %w(abc123 def456)

    keys_file.write! keys
    expect(tempfile.read).to include keys.join("\n")

    keys_file.delete! keys.first
    expect(tempfile.read).to_not include keys.first

    keys_file.delete! keys.last
    expect(tempfile.read).to_not include keys.last

    expect(tempfile.read).to be_empty
  end
end
