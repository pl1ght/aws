require 'aws-sdk'

# Shared credentials and Cloudwatch client
credentials = Aws::SharedCredentials.new(profile_name: 'imagingdev')
@cloudwatch = Aws::CloudWatch::Client.new(credentials: credentials, region: 'us-east-1')

@startdate = (DateTime.now - 14).iso8601
@enddate = DateTime.now.iso8601
volume_id = "vol-f3323b13"

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

def ebs_candidate(volume_id)
  metrics = ebs_metrics(volume_id)
  if metrics.length
    for metric in metrics
      if metric['minimum']
        return True
      else
        print "False"
      end
    end
  end
end

ebs_metrics(volume_id)
ebs_candidate(volume_id)



