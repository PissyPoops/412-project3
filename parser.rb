require 'open-uri'
require 'date'
require 'time'
require 'pp'

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

def incrementor(h,a)
  h[a] = (
    if h[a] then
      h[a]+= 1
    else
      1
    end)
end

#Asks user if they'd like to download the file(procede with program)
puts 'Would you like to retrieve the file for parsing? (Y/N)'
response = gets.chomp.upcase
#response.upcase!
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
  #y_m_d = []   Include this later?
  unix_time = full_date.to_i
	request = delimited[2]
	file_request = delimited[3]
	status = delimited[5]
  
  incrementor(monthly_requests, y_m)
  incrementor(file_frequency, file_request)
  incrementor(statuses, status)

end

puts total_requests
puts monthly_requests
puts largest_hash(file_frequency)
puts statuses


########################################################################
puts "################################1#################################"
puts total_requests

########################################################################
puts "################################2#################################"
monthly_requests_a = monthly_requests.to_a
monthly_requests_a.each do |date, requests|
  puts "#{date}, #{requests}"
end

########################################################################
puts "################################3#################################"
unsuccessful_requests = (((statuses['404'].to_f+ statuses['403'].to_f)/total_requests)*100)
puts unsuccessful_requests

########################################################################
puts "################################4#################################"
redirected_requests = (((statuses['302'].to_f+ statuses['304'].to_f)/total_requests)*100)
puts redirected_requests

########################################################################
puts "################################5#################################"
puts largest_hash(file_frequency)
puts largest_hash(file_frequency).length


########################################################################
puts "################################6#################################"
file_frequency_least = smallest_hash(file_frequency).to_a.sort

if file_frequency_least.length > 100
  puts "There are over #{file_frequency_least.length} individual files that have been requested only once."
  puts "Would you like to view all of these individual files?" + "\n\n"
  file_least_response = gets.chomp.upcase
  if file_least_response == 'Y'
    file_frequency_least.each do |file, requests|
      print "#{file}"
      puts
    end
  else
    puts "OK. Not printing #{file_frequency_least.length} files." + "\n\n"
  end
  else
  file_frequency_least.each do |file, requests|
    print "#{file} "
    puts
  end
end
    
  
#file_frequency_least.each do |file, requests|
#    puts "#{file} -- #{requests}"
#end
