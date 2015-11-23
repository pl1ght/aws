# aws
aws-sdk ruby v2 testing

awsauth.rb just does an authenticate and s3 bucket list per user input region, then list contents of bucket

ec2id.rb allows user to auth via credentials file profiles and lists via Name tag/instance_id/powerstate.  Need to add in handling instances with no tags

iamcreate.rb quick script that allows user to input how many IAM users an the script will randomly generate a userXXXXX and random base64 password and create them on the AWS account profile specified. Had to do this for a lab account we were setting up for an AWS immersion day. Quick and easy.
