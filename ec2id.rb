require 'aws-sdk'
require 'pry'
require 'json'


# Grab AWS access/secret keys from .aws/credentials file

# ssl_verify_peer = not good practice, but on Windows systems its a quick workaround until you can set your environment for a proper CA-bundle

#Aws.config[:ssl_verify_peer] = false
credentials = Aws::SharedCredentials.new(profile_name: 'default')
awsregion = "us-east-1"
client = Aws::EC2::Client.new(credentials: credentials, region: "#{awsregion}")

resp = client.describe_instances          #describe_instance_status

resp.reservations.each do |res|
  res.instances.each do |inst|
    iid = inst[:instance_id]
    istate = inst[:state].name
    itag = inst.tags[0].value
    puts "#{itag} | #{iid} | #{istate}"
  end
end














