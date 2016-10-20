require 'open-uri'
require 'date'

#1 - Make user customizable
remoteFile = 'http://s3.amazonaws.com/tcmg412-fall2016/http_access_log'

#2 - Change file location to obvious Linux-friendly
localFile = 

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
  File.write('/mnt/c/Users/John/Downloads/test', download)
end

#puts localFile
