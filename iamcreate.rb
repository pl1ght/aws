require 'aws-sdk'
require 'securerandom'

credentials = Aws::SharedCredentials.new(profile_name: 'changeme')
iam = Aws::IAM::Resource.new(credentials: credentials, region: 'us-east-1')

puts "Enter Number of IAM users to create: "
maxcount = gets.chomp.to_i
count = 0


while count < maxcount do
  num = rand(10000)
  user = "user" + "#{num}"
  password = SecureRandom.base64(5)
  iamuser = iam.create_user(user_name: "#{user}")
  iamuser.create_login_profile(password: "#{password}", password_reset_required:false)

  print user + " "
  print password + "\n"
  count = count + 1
end

puts  "Finished"

