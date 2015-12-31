require 'aws-sdk'
#Aws.use_bundled_cert!  #for systems that do not have latest/greatest CA bundle install/configured properly. Uncomment if needing workaround.
require_relative 'profile.rb'

# Call function from profile.rb to get account/region info
awsprofile

credentials = Aws::SharedCredentials.new(profile_name: @profile.downcase)
@client = Aws::EC2::Client.new(credentials: credentials, region: @region.downcase)

resp = @client.describe_volumes({ filters:[{name: "status", values: ["available"]}]})


@ebsvol = resp.volumes.map
@ebsavailable = []


def ebs_available
  for i in @ebsvol do
    @ebsavailable << i.volume_id
  end
end

def ebs_delete
  for i in @ebsavailable
    @client.delete_volume({dry_run: true, volume_id: "#{i}",})
  end
end

ebs_available
ebs_delete