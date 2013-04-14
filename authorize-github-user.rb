require 'httparty'

username = 'chrishunt'
authorized_keys_path = '~/.ssh/authorized_keys'
response = HTTParty.get "https://api.github.com/users/#{username}/keys"

if response.code == 200
  puts "Found #{response.count} key#{'s' if response.count > 1} on Github for '#{username}'"
  puts "Adding keys to #{authorized_keys_path}"

  File.open authorized_keys_path, 'a+' do |file|
    file << response.map { |entry| entry['key'].strip }.join("\n")
  end

  puts "Done"
else
  puts "Could not find keys for '#{username}' on Github"
end
