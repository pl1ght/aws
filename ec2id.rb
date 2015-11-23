require 'aws-sdk'
#Aws.use_bundled_cert!  #for systems that do not have latest/greatest CA bundle install/configured properly. Uncomment if needing workaround.
require 'json'


# Grab AWS access/secret keys by profile from .aws/credentials file

# Windows
winuser = ENV['USERPROFILE']
credentialfile = "#{winuser}/.aws/credentials"

# Linux
#nixuser = ENV['HOME']
#credentialfile = "#{nixuser}/.aws/credentials"

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
  # Check for instances with no Tags
    if inst.tags.nil?
      itag = "!!!NO TAG!!!"
    else
      itag = inst.tags[0].value
    end
    puts "#{itag} | #{iid} | #{istate}"
  end
end














