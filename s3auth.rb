require 'aws-sdk'
#require 'pry'

def s3_get_objects

# Grab AWS access/secret keys from .aws/credentials file

  # ssl_verify_peer = not good practice, but on Windows systems its a quick workaround until you can set your environment for a proper CA-bundle
  def awscredentials
   #Aws.config[:ssl_verify_peer] = false
    @credentials = Aws::SharedCredentials.new(profile_name: 'default')
  end

  # Define Region
  def regions
    puts 'Specify AWS Region: '
    @awsregion = gets.chomp
  end

# Define new connection to AWS S3
  def s3connect
    awscredentials
    regions
    @s3 = Aws::S3::Client.new(credentials: @credentials, region: "#{@awsregion}")
  end

  def gets3buckets
    @s3.list_buckets.each do |response|
      puts response.buckets.map(&:name)
    end

      puts "\nSpecify Bucket: "
    @s3bucket = gets.chomp
  end

  s3connect
  gets3buckets

  @s3.list_objects(bucket:"#{@s3bucket}").each do |response|
    puts response.contents.map(&:key)
  end
end

s3_get_objects
