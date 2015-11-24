  require 'aws-sdk'
  require 'json'



  # Credentials pulled via .aws/credentials file via profiles
  credentials = Aws::SharedCredentials.new(profile_name: 'ro')

  # Create ELB client
  elb = Aws::ElasticLoadBalancing::Client.new(credentials: credentials, region: 'us-east-1')

  resp = elb.describe_load_balancers
  @lbname = resp.load_balancer_descriptions.each

  # Iterate through load balancer descriptions to pull all load balancer names
  def lb_name()
    while @lbname do
      puts @lbname.next.load_balancer_name
    end
  end

  lb_name














