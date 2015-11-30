require 'aws-sdk'
#Aws.use_bundled_cert!  #for systems that do not have latest/greatest CA bundle install/configured properly. Uncomment if needing workaround.
require_relative 'profile.rb'

# Call function from profile.rb to get account/region info
awsprofile

credentials = Aws::SharedCredentials.new(profile_name: @profile.downcase)
client = Aws::EC2::Client.new(credentials: credentials, region: @region.downcase)

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
    puts "#{itag} - #{iid} - #{istate}"
  end
end














