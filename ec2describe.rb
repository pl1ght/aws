require 'aws-sdk'

# Just a quick script for me to change filters/options/etc on for information/testing

@profile = "profilename"

# Array Init
instance = "i-f7e4df41"
# Shared credentials and EC2 client
credentials = Aws::SharedCredentials.new(profile_name: @profile)
@client = Aws::EC2::Client.new(credentials: credentials, region: 'us-east-1')


resp = @client.describe_instances({
                                  instance_ids: [instance],
                                      filters: [

                                          {
                                              name: 'instance-state-name',
                                              values: ['stopped'],
                                          }
                                      ]
                                  })

begin
  @client.terminate_instances({
      instance_ids: [instance]
                              })
rescue Aws::EC2::Errors::ServiceError
  puts "#{instance} has termination protection turned on"
end
