require 'aws-sdk'
require 'logger'

@profile = "ro"
@stopped_instances = []
@candidates = []
@notcandidate = []

# Shared credentials and EC2 client
credentials = Aws::SharedCredentials.new(profile_name: @profile)
@client = Aws::EC2::Client.new(credentials: credentials, region: 'us-east-1')
@cloudwatch = Aws::CloudWatch::Client.new(credentials: credentials, region: 'us-east-1')

# Date variables I am using 14 days/2 weeks to look back for Cloudwatch metrics
@startdate = (DateTime.now - 14).iso8601
@enddate = DateTime.now.iso8601

@resp = @client.describe_instances({
                                       filters: [
                                           {
                                               name: 'instance-state-name',
                                               values: ['stopped'],
                                           }
                                       ]
                                   })
def get_instances
  @resp.reservations.each do |i|
    @stopped_instances.push(i.instances[0][:instance_id])
  end
end

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
get_instances

@stopped_instances.each do |i|
  ec2_candidate(i)
end

#@stopped_instances.each do |i|
#  @candidates.push(get_ec2_metrics(i))
#end
p @stopped_instances.count
p @candidates.count
p @notcandidate.uniq.count