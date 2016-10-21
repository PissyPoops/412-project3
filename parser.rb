require 'open-uri'
require 'date'
require 'time'

totals = Hash.new
file_frequency = Hash.new
statuses = Hash.new

unix_time = []
#daily_requests= Hash.new
monthly_requests = Hash.new

failure_array = []

#CHANGE1 Give user option to declare if they're on Windows or PC
#CHANGE1 Make user customizable

remote_file = 'http://s3.amazonaws.com/tcmg412-fall2016/http_access_log'

#CHANGE2 Change file save location to obvious Linux-friendly
local_file = 'log_file.txt'
test_file = 'log_file_shortened.txt'

def largest_hash(hash)
  max = hash.values.max
  Hash[hash.select { |k,v| v == max }]
end

def smallest_hash(hash)
  min = hash.values.min
  Hash[hash.select { |k,v| v == min }]
end

#Asks user if they'd like to download the file(procede with program)
puts 'Would you like to retrieve the file for parsing? (Y/N)'
response = gets.chomp
response.upcase!
if response == "Y" 
  puts "Downloading log file from " + remote_file
  puts
  
  download = open(remote_file)
  IO.copy_stream(download, local_file)
  
  puts "The file " + remote_file + " has been downloaded and saved to your directory."
  puts 
  else
  puts "Then I have nothing to offer you..."
end


#Counts the total number of requests (lines) in the file. 
File.foreach(test_file) {}
total_requests = $.

i = 0
#Loops through saved file
File.foreach(test_file) do |x|
	delimited = /.*\[(.*) \-[0-9]{4}\] \"([A-Z]+) (.+?)( HTTP.*\"|\") ([2-5]0[0-9]) .*/.match(x)
  if !delimited
    failure_array.push(x)
    next
  end
  
	# Grab the data from the fields we care about
	full_date = Time.strptime(delimited[1], '%d/%b/%Y:%H:%M:%S')
	y_m = full_date.strftime('%Y-%m')
	request = delimited[2]
	file_request = delimited[3]
	status = delimited[5]
  
  file_frequency[file_request] = (
    if file_frequency[file_request] then 
      file_frequency[file_request]+=1 
    else 
      1 
    end)
    
  statuses[status] = (
    if statuses[status] then
      statuses[status]+= 1
    else
      1
    end)
  
  monthly_requests[y_m] = (
    if monthly_requests[y_m]
      monthly_requests[y_m] += 1
    else
      1
    end)
    
  #if by_month[y_m] == false
    #by_month[y_m] = []
  #end
  
  unix_time = full_date.to_i
  
end

#def incrementor(hash,array)
#  hash()
#end
puts monthly_requests




############################################################
#outputs
##################################


#puts "Total requests: " + total_requests
#puts "Daily requests =: " + 
#puts "Unsucessful requests: "
#puts "Redirected requests: "
#puts "Most requested file: "
#puts "Least requested file: "
