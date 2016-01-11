require 'aws-sdk'
require 'logger'
require 'json'

@log = Logger.new('ec2cleanup.log','weekly')
@profile = "imagingdev"

# Array Init
@stopped_instances = []
@candidates = []
@notcandidate = []
@info = []

# Shared credentials and EC2 client
credentials = Aws::SharedCredentials.new(profile_name: @profile)
@client = Aws::EC2::Client.new(credentials: credentials, region: 'us-east-1')
@cloudwatch = Aws::CloudWatch::Client.new(credentials: credentials, region: 'us-east-1')

# Date variables I am using 30 days to look back for Cloudwatch metrics
@startdate = (DateTime.now - 30).iso8601
@enddate = DateTime.now.iso8601

# Aws Client looking for only stopped instances
@resp = @client.describe_instances({
                                       filters: [
                                           {
                                               name: 'instance-state-name',
                                               values: ['stopped'],
                                           }
                                       ]
                                   })

# Fill up our stopped_instances array with all found in account
def get_instances
  @resp.reservations.each do |i|
    @stopped_instances.push(i.instances[0][:instance_id])
  end
end


# Look for CPUutilization metrics
def get_ec2_metrics(ec2_id)
  resp =  @cloudwatch.get_metric_statistics({
                                                namespace: "AWS/EC2",
                                                metric_name: "CPUUtilization",
                                                dimensions: [
                                                    {
                                                        name: "InstanceId",
                                                        value: ec2_id,
                                                    },
                                                ],
                                                start_time: @startdate,
                                                end_time: @enddate,
                                                period: 3600,
                                                statistics: ["Minimum"],
                                                unit: "Percent"
                                            })
  resp.datapoints
end

# Check to see if any stopped instances are candidates for deletion based on any CPU activity in last 30 days
def ec2_candidate(ec2_id)
  metrics = get_ec2_metrics(ec2_id)
  if metrics.length
    metrics.each do |metric|
      if metric['minimum']
        @notcandidate.push(ec2_id)
      end
    end
  end
  if metrics.empty?
    @candidates.push(ec2_id)
  end
end


# We may want more info on the instances initially to cross check our stopped instances with others before deletion.
def get_candidate_tags
  @candidates.each do |iid|
    itag = @client.describe_tags(filters: [{name: "resource-id", values: [iid]},{name: "key", values: ["Name"]}])
    @info.push(itag)
  end
end

# Get the instances that are stopped
get_instances

# Loop through each instance thats stopped and run against cloudwatch for CPU Metrics
@stopped_instances.each do |i|
  ec2_candidate(i)
end

# Get dat tag from instances
get_candidate_tags

# I print these values so I can make sure the math is right. For Debugging purposes
p @stopped_instances.count
p @candidates.count
p @notcandidate.uniq.count

# Dump out the instanceID and tags in json format
@info.each do |i|
  a = i.to_h
  @log.info(JSON.pretty_generate(a[:tags]))
end


# Terminate instances and log
@candidates.each do |del|
  @client.terminate_instances({
      dry_run: false,
      instance_ids: [del],
                              })
  @log.info "Deleted #{del}"
end
