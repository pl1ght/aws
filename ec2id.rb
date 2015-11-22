require 'aws-sdk'
require 'json'


# Grab AWS access/secret keys by profile from .aws/credentials file

# Windows
#credentialfile = 'C:/Users/user/.aws/credentials'

# Linux
#credentialfile = '~user\.aws\credentials'

list_creds = File.open credentialfile do |file|
  file.find_all { |line| line =~ /\[\w+\]/ }
end

puts list_creds
puts "Select profile: "
profile = gets.chomp

puts "Specify Region: "
region = gets.chomp

credentials = Aws::SharedCredentials.new(profile_name: profile )
client = Aws::EC2::Client.new(credentials: credentials, region: region )

resp = client.describe_instances

resp.reservations.each do |res|
  res.instances.each do |inst|
    iid = inst[:instance_id]
    istate = inst[:state].name
    itag = inst.tags[0].value
    puts "#{itag} | #{iid} | #{istate}"
  end
end














