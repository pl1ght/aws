require 'aws-sdk'

# Grab AWS access/secret keys by profile from .aws/credentials file
# Windows
winuser = ENV['USERPROFILE']
credentialfile = "#{winuser}/.aws/credentials"

# Linux
#nixuser = ENV['HOME']
#credentialfile = "#{nixuser}/.aws/credentials"

list_creds = File.open credentialfile do |file|
  file.find_all { |line| line =~ /\[\w+\]/ }
end

puts list_creds
puts "Select profile: "
profile = gets.chomp

puts "Enter AWS region: "
region = gets.chomp

# Credentials pulled via .aws/credentials file via profiles
credentials = Aws::SharedCredentials.new(profile_name: profile)

# Create EC2 client
@ec2stat = Aws::EC2::Client.new(credentials: credentials, region: "#{region}")
@ec2ctrl = Aws::EC2::Resource.new(credentials: credentials, region: "#{region}")

def start_instances()
  instance = @ec2ctrl.instance("#{@iid}")
  instance.start
  instance.wait_until_running
   puts instance.id + " has been started successfully"
end

def stop_instances()
  instance = @ec2ctrl.instance("#{@iid}")
  instance.stop
  instance.wait_until_stopped
  puts instance.id + " has been stopped successfully"
end

def status_instance()
  instance = @ec2stat.describe_instance_status({instance_ids: [@iid], include_all_instances: true})
  puts "Instance #{@iid} is " + instance.instance_statuses[0].instance_state.name
  #ctrl
end

def ctrl()
  puts "Enter Instance_ID: "
  @iid = gets.chomp
  status_instance
  puts "Start or stop instance? "
  @cmd = gets.chomp
    if @cmd.downcase == "start"
    start_instances
  elsif @cmd.downcase == "stop"
    stop_instances
  elsif defined?(@cmd)
    ctrl
  end
end

ctrl



