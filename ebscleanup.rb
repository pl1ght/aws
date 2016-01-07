#!/usr/bin/env ruby

require 'aws-sdk'
require 'logger'

@profile = 'ro'
# Shared credentials and Cloudwatch client
credentials = Aws::SharedCredentials.new(profile_name: @profile)

# EBS Client
@client = Aws::EC2::Client.new(credentials: credentials, region: 'us-east-1')

# Populate EBS volumes in available state
resp = @client.describe_volumes({ filters:[{name: 'status', values: ['available']}]})
@ebsvol = resp.volumes.map

# Cloudwatch client
@cloudwatch = Aws::CloudWatch::Client.new(credentials: credentials, region: 'us-east-1')

# Date variables I am using 14 days/2 weeks to look back for Cloudwatch metrics
@startdate = (DateTime.now - 14).iso8601
@enddate = DateTime.now.iso8601

# Setup arrays
@volume_id = []
@candidates = []
@notcandidate = []

# Setup Logging
@log = Logger.new('ebscleanup.log','weekly')

# Find our EBS Volumes in available status
def ebs_available
  @ebsvol.each do |i|
    @volume_id.push(i.volume_id)
  end
end

# Cloudwatch metric to pull minimum Idle time for EBS volumes to see which volumes are not used.
def ebs_metrics(volume_id)
  resp =  @cloudwatch.get_metric_statistics({
     namespace: 'AWS/EBS',
      metric_name: 'VolumeIdleTime',
      dimensions: [
          {
              name: 'VolumeId',
              value: volume_id,
          },
      ],
      start_time: @startdate,
      end_time: @enddate,
      period: 3600,
      statistics: ['Minimum'],
      unit: 'Seconds'
  })
  resp.datapoints
end

# Verify metrics exist for volume, we are making an assumption if any 'minimum' metric exists, it is potentially in use.  Empty metric returns are added as candidates
def ebs_candidate(volume_id)
  metrics = ebs_metrics(volume_id)
  if metrics.length
    metrics.each do |metric|
      if metric['minimum']
        @notcandidate.push(volume_id)
      end
    end
  end
  if metrics.empty?
    @candidates.push(volume_id)
  end
end

# Get candidates for deletion
def get_candidate
  @volume_id.each do |i|
    ebs_metrics(i)
    ebs_candidate(i)
  end
end

# Log and delete candidate volumes - note dry_run: false.  Set to true if you want to actually dry run. false WILL *delete*.
def ebs_delete
  @candidates.each do |i|
    @client.delete_volume({dry_run: false, volume_id: i,})
    @log.info "Account #{@profile} - deleting #{i}"
  end
end

def ebs_delete_dry
  @candidates.each do |i|
    @log.info "--DRY RUN-- Account #{@profile} - Found candidate #{i}"
  end
end

# Logging non-candidate for awareness. Since I am being dumb about potentially returning True multiple times for cloudwatch metrics, added .uniq to array so it only prints one volume_id per loop.
def ebs_notcandidate
  @notcandidate.uniq.each do |i|
    @log.info "Account #{@profile} - Volume #{i} has recently been in use, skipping..."
  end
end

# Do the things and command-line the tool
case ARGV[0]
  when 'dry-run'
    ebs_available
    get_candidate
    ebs_delete_dry
    ebs_notcandidate
  when 'run'
    ebs_available
    get_candidate
    ebs_delete
    ebs_notcandidate
  else
    STDOUT.puts <<-EOF
Please provide command option

Usage:
  ebscleanup.rb dry-run **outputs EBS candidates for deletion to ebscleanup.log**
  ebscleanup.rb run **deletes all valid EBS candidates and logs to ebscleanup.log**
EOF
end

