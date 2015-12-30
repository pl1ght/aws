require 'aws-sdk'
#Aws.use_bundled_cert!  #for systems that do not have latest/greatest CA bundle install/configured properly. Uncomment if needing workaround.
require_relative 'profile.rb'

# Call function from profile.rb to get account/region info
awsprofile

credentials = Aws::SharedCredentials.new(profile_name: @profile.downcase)
client = Aws::EC2::Client.new(credentials: credentials, region: @region.downcase)

resp = client.describe_volumes({ filters:[{name: "status", values: ["available"]}]})

@ebsvol = resp.volumes.map
@ebsavailable = []


for i in @ebsvol do
  @ebsavailable << i.volume_id
end
@count = @ebsavailable.count
puts "#{@count} currently unused volumes in #{@region} #{@profile}"
puts @ebsavailable