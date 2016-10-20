require 'open-uri'
require 'date'

#CHANGE1 Make user customizable
remoteFile = 'http://s3.amazonaws.com/tcmg412-fall2016/http_access_log'

#CHANGE2 Change file save location to obvious Linux-friendly
localFile = 'log_file.txt'

#Asks user if they'd like to download the file
puts 'Would you like to retrieve the file for parsing? (Y/N)'
response = gets.chomp
response.upcase!

totals = Hash.new
files = Hash.new
counter = Hash.new
errors = Hash.new

#If the users responds affirmative, downloads the file and saves it locally
if response == "Y" 
  puts "Downloading log file from " + remoteFile
  download = open(remoteFile)
  IO.copy_stream(download, localFile)
  else
  puts "Then I have nothing to offer you..."
end

#puts localFile
