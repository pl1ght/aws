# aws
**aws-sdk ruby v2** 
- Scripts that are from larger ChatOps projects, lita.io bot specifically, that I made into one off runnable single scripts for future reference, or others looking for ruby aws SDK v2 info


**s3auth.rb** - just does an authenticate and s3 bucket list per user input region, then list contents of bucket specified

**ec2id.rb** - allows user to auth via credentials file profiles and lists via Name tag/instance_id/powerstate. 

**iamcreate.rb** - quick script that allows user to input how many IAM users requested. Then, the script will randomly generate a userXXXXX with a random base64 password, and create them on the AWS account profile specified. Had to do this for a lab account we were setting up for an AWS immersion day. Quick and easy.

**elbec2id.rb** - pulls instance_id's, each instance_id's IP address, and the instance health for all instances registered with the specified ELB.

**elblist.rb** - enumerates and lists all ELBs for a given profile in AWS 

**ec2ctrl.rb** - specify a region and instance-id.  Will get status of instance power, or let you power on/off depending on command issues

**profile.rb** - function to grab region/credential profile specs to feed scripts.

**ebscleanup.rb** - Script that queries all available EBS volumes in an AWS account, cross checks each volume_id with CloudWatch metrics to see if it is a good candidate for deletion, and deletes if it is.  Has command-line functionality and ability to dry-run to log what would be deleted.

**ec2cleanup.rb** - CMD-Line Script that queries all stopped EC2 instances for an AWS account, cross checks the instance with CloudWatch for CPUusage in past 60 days(configurable), and puts it as a candidate for deletion if user wish to terminate.  Dry run also just ouputs candidates to logfile