require 'aws-sdk'
require 'logger'

@profile = "ro"
@stopped_instances = []
@instance_ebs = []
@volume_size = []

# Shared credentials and EC2 client
credentials = Aws::SharedCredentials.new(profile_name: @profile)
@client = Aws::EC2::Client.new(credentials: credentials, region: 'us-east-1')

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

def get_volumes
  @resp.reservations.each do |i|
    @instance_ebs.push(i.instances[0].block_device_mappings[0][:ebs].volume_id)
  end
end

def get_volume_size
  @instance_ebs.each do |i|
    @ebsresp = @client.describe_volumes({
                                          volume_ids: [i]
                                      })
    @volume_size.push(@ebsresp.volumes[0].size)
  end
end
get_instances
get_volumes
get_volume_size
a = @volume_size.reduce(:+)
price = a * ".10".to_f
p "$#{price}"
#p @instance_ebs.count
#p @stopped_instances.count
