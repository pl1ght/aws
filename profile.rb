def awsprofile
  # Grab AWS access/secret keys by profile from .aws/credentials file
  # Windows
#  @winuser = ENV['USERPROFILE']
#  @credentialfile = "#{@winuser}/.aws/credentials"

# Linux/OSX
@nixuser = ENV['HOME']
@credentialfile = "#{@nixuser}/.aws/credentials"

  list_creds = File.open @credentialfile do |file|
    file.find_all { |line| line =~ /\[\w+\]/ }
  end

# List available profiles in local credentials file
  puts list_creds
  puts "Select profile: "
  @profile = gets.chomp

# Get AWS region
  puts "Enter AWS region: "
  @region = gets.chomp
end

