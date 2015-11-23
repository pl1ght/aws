  require 'aws-sdk'
  require 'securerandom'
  require 'csv'

  # Set Creds as usual via $home/.aws/credentials - You aren't storing keys in code are you? :)
  credentials = Aws::SharedCredentials.new(profile_name: 'changeme')

  # Create IAM Client
  iam = Aws::IAM::Resource.new(credentials: credentials, region: 'us-east-1')

  # Enter how many random users you want to create
  puts "Enter Number of IAM users to create: "
  maxcount = gets.chomp.to_i
  count = 0

  # Init array for user/pass infos
  csvout = []

  # While Loop to handle IAM user and random base64 password generation
  while count < maxcount do
    num = rand(10000)
    user = "user" + "#{num}"
    password = SecureRandom.base64(5)
    iamuser = iam.create_user(user_name: "#{user}")
    iamuser.create_login_profile(password: "#{password}", password_reset_required:false)
    csvout << user + "," + password #+ "\n"

  # CSV File creation, creates file where script was run.  Did this for a "paper" copy
  CSV.open("iamcreds.csv", "w") do |csv|
    csvout.each do |x|
    csv << [x]
      end
    end
  count = count + 1
  end


puts  "\nFinished"

