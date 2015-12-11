require 'aws-sdk'
#Aws.use_bundled_cert!  #for systems that do not have latest/greatest CA bundle install/configured properly. Uncomment if needing workaround.
require_relative 'profile.rb'

# Call function from profile.rb to get account/region info
awsprofile

credentials = Aws::SharedCredentials.new(profile_name: @profile.downcase)
client = Aws::DynamoDB::Client.new(credentials: credentials, region: @region.downcase)

resp = client.describe_table({table_name: "tablename",})
count =  resp.table.item_count


puts count