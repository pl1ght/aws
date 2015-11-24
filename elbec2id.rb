require 'json'
require 'aws-sdk'


# Initialize Arrays
ec2_ids=[]

# Credentials pulled via .aws/credentials file via profiles
credentials = Aws::SharedCredentials.new(profile_name: 'ro')

# Create ELB client
elb = Aws::ElasticLoadBalancing::Client.new(credentials: credentials, region: 'us-east-1')
elbname = "ELB-Name"

# Describe ELB specified
elbid = elb.describe_load_balancers(options = {:load_balancer_names => ["#{elbname}"]})


# Grab every instance behind an ELB
elbid[:load_balancer_descriptions].first[:instances].each do |instance|
  ec2_ids << instance.instance_id
end

# Create EC2 Client
ec2 = Aws::EC2::Client.new(credentials: credentials, region: 'us-east-1')

# Grab private IP address from each instance retrieved from ELB in previous block and populate ID/IP for each
ec2_ids.each do |i|
  aws_id = ec2.describe_instances(options = {:instance_ids => ["#{i}"]})
  aws_id_resp = aws_id[:reservations].first[:instances].first[:private_ip_address]
  aws_elb_resp = elb.describe_instance_health({load_balancer_name: "#{elbname}", instances:[{ instance_id: "#{i}"}]})
  puts "#{ec2_ids} - #{aws_id_resp} - ELB Health = " + aws_elb_resp.instance_states[0].state
end
