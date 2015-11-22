require 'aws-sdk'
require 'pry'
require 'json'


# Grab AWS access/secret keys/region by profile from .aws/credentials file

credentials = Aws::SharedCredentials.new(profile_name: 'default')
client = Aws::EC2::Client.new(credentials: credentials)

resp = client.describe_instances

resp.reservations.each do |res|
  res.instances.each do |inst|
    iid = inst[:instance_id]
    istate = inst[:state].name
    itag = inst.tags[0].value
    puts "#{itag} | #{iid} | #{istate}"
  end
end














