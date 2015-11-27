require 'aws-sdk'


puts "Enter AWS region: "
region = gets.chomp

# Credentials pulled via .aws/credentials file via profiles
credentials = Aws::SharedCredentials.new(profile_name: 'imagingdev')

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
  puts "status/start/stop instance: "
  @cmd = gets.chomp
  if @cmd == "start"
    start_instances
  elsif @cmd == "stop"
    stop_instances
  elsif @cmd == "status"
    status_instance
  elsif defined?(@cmd)
    ctrl
  end
end

ctrl



