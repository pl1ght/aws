require 'aws-sdk'
require 'logger'
require 'json'

# Logging options
@log = Logger.new('ec2cleanup.log','weekly')
@log_candidate = Logger.new('ec2candidates.log','weekly')

# shared profile account
@profile = "default"

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
@startdate = (DateTime.now - 60).iso8601
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

# Look for CPUutilization metrics over specified timeframe
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

# Getting Tags for stopped instances- We may want more info on the instances initially to cross check our stopped instances with others before deletion.
def get_candidate_tags
  @candidates.each do |iid|
    itag = @client.describe_tags(filters: [{name: "resource-id", values: [iid]},{name: "key", values: ["Name"]}])
    @info.push(itag)
  end
end

# Loop through each instance thats stopped and run against cloudwatch for CPU Metrics
def inst_cloudwatch
  @stopped_instances.each do |i|
   ec2_candidate(i)
end
end

# Dump out the instanceID and tags in json format
def log_instances
@info.each do |i|
  a = i.to_h
  @log_candidate.info(JSON.pretty_generate(a[:tags]))
end
end

# Terminate instances and log with error handling around Termination protection
def term_instances
  @candidates.each do |del|
    begin
      @client.terminate_instances({
            dry_run: false,
            instance_ids: [del],
                                })
      puts "Deleting instance #{del}"
      @log.info "Deleted #{del}"
    rescue Aws::EC2::Errors::ServiceError => e
      @log.warn e.message
      puts "#{del} can't be deleted, please check logfile for more information"
    next
    end
  end
end

# Command-line options required
case ARGV[0]
  when 'dry-run'
    get_instances
    inst_cloudwatch
    get_candidate_tags
    log_instances
    # Print out total stopped found and how many are candidates and the difference to verify math is as expected.
    puts "Total stopped instances: #{@stopped_instances.count}"
    puts "Total candidates for deletion: #{@candidates.count}"
    puts "Total instances NOT candidates for deletion: #{@notcandidate.uniq.count}"
  when 'run'
    get_instances
    inst_cloudwatch
    get_candidate_tags
    term_instances
  else
    STDOUT.puts <<-EOF
Please provide command option

Usage:
  ec2cleanup.rb dry-run **outputs EC2 deletion candidates to ec2candidates.log**
  ec2cleanup.rb run **deletes all valid EC2 candidates and logs to ec2cleanup.log**
    EOF
end
