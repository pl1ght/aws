require 'aws-sdk'

# Shares credentials and Cloudwatch client
credentials = Aws::SharedCredentials.new(profile_name: 'imagingdev')
@cloudwatch = Aws::CloudWatch::Client.new(credentials: credentials, region: 'us-east-1')

@startdate = (DateTime.now - 14).iso8601
@enddate = DateTime.now.iso8601

# Cloudwatch metric to pull minimum Idle time for EBS volumes to see which volumes are not used.

def ebs_metrics(volume_id)
  resp =  @cloudwatch.get_metric_statistics({
     namespace: "AWS/EBS",
      metric_name: "VolumeIdleTime",
      dimensions: [
          {
              name: "VolumeId",
              value: volume_id,
          },
      ],
      start_time: @startdate,
      end_time: @enddate,
      period: 3600,
      statistics: ["Minimum"],
      unit: "Seconds"
  })
  resp.datapoints
end

ebs_metrics("vol-idxxxx")



