require 'open-uri'
require 'date'

def winsize   #Finds user's console size for better formatting of output data
  require 'io/console'
  IO.console.winsize
  rescue LoadError
  [Integer(`tput li`), Integer(`tput co`)]
end

def largest_hash(hash)    #Finds ALL of the max values from an array. Allows for ties.
  max = hash.values.max
  Hash[hash.select { |k,v| v == max }]
end

def smallest_hash(hash)   #Finds ALL the minimum values from an array. Allows for ties.
  min = hash.values.min
  Hash[hash.select { |k,v| v == min }]
end

def incrementor(h,a)    #Counts repetition of keys in hashes and stores it as a value.
  h[a] = (
    if h[a] then
      h[a]+= 1
    else
      1
    end)
end

def question_formatter(q_num)   #Quicker way for me to format the outputs for the project's questions.
  puts "\n\nQuestion #{q_num}".center(@columns)
  puts "".center((@columns), "~")+"\n"
end

def download_menu()
  puts "\n\n"
  puts " -----Please select a file to download-----".center(@columns)
  puts "             ___________________________________________________________________________________ "
  puts "  Press [1] |       Amazon      | URL: http://s3.amazonaws.com/tcmg412-fall2016/http_access_log |"
  puts "     for    |  (for remote use) |                                                               |"
  puts "            |------------------------------------------------------------------------------------"
  puts "  Press [2] |       TAMU        | URL: http://physis.arch.tamu.edu/files/http_access_log        |"
  puts "     for    |  (for local use)  |                                                               |"
  puts "            |-----------------------------------------------------------------------------------|\n"
  puts "  or press [C] to enter a custom URL.\n\n"
  puts "Please enter a download source (1, 2, or C)\n\n".center(@columns)
end

def download_selector(x)
  file = x
  puts "URL selected. Downloading from '#{file}'.".center(@columns)
  download_loc = file
  download = open(file)
  IO.copy_stream(download, @log_file)
  puts "The file has been downloaded and saved to your directory.\n".center(@columns)
  puts "Starting parsing operation. This could take a couple minutes...".center(@columns)
end

#Initializes hashes and arrays
totals, file_frequency, statuses, monthly_requests, monthly_requests_count = {},{},{},{},{}
failure_array = []

#Sets variables for IO access
amazon_file = 'http://s3.amazonaws.com/tcmg412-fall2016/http_access_log'
local_file = 'http://physis.arch.tamu.edu/files/http_access_log'
custom_file= ''
@log_file = 'log_file.txt'
splitter_path = 'logs_by_month/'
@rows, @columns = winsize

#Ask user if they'd like to execute the program
puts "\n"
puts "  Apache Log Parser - TCMG 304  ".center(@columns)
puts "  Begin parsing? (Y/N)  ".center(@columns)
response = gets.chomp.upcase

if response == "Y"
  download_menu()
  download_conf = gets.chomp.to_s.downcase
  if download_conf == "1"
    download_selector(amazon_file)
  elsif download_conf == '2'  
    download_selector(local_file)
  elsif download_conf == "c"
    puts "Please enter a URL: ".center(@columns)
    custom_file = gets.chomp.downcase
    download_selector(custom_file)
  else
    puts "I don't know what that means..." end
else 
puts "\n\n     ...fine then. \n\n"
abort()
end

#Counts the total number of requests (lines) in the file. 
File.foreach(@log_file) {}
total_requests = $.

#Loops through the log file for parsing. 'Borrowed' alot of 
#this from Adam since my previous methodwas so inefficient.
File.foreach(@log_file) do |data|
	delimited = /.*\[(.*) \-[0-9]{4}\] \"([A-Z]+) (.+?)( HTTP.*\"|\") ([2-5]0[0-9]) .*/.match(data)
  if !delimited    #Sanity checker (literally...)
    failure_array.push(data)
    next
  end
  
	# Collect groups from @delimited and organizes them into arrays.
	full_date = Time.strptime(delimited[1], '%d/%b/%Y:%H:%M:%S')
	y_m = full_date.strftime('%Y-%m')
  file_request = delimited[3]
	status = delimited[5]

  unless monthly_requests[y_m]    #Creates arrays based on the year and month. Used to divide the log file into year-month files
    monthly_requests[y_m] = [] end
  monthly_requests[y_m].push(data)
  
  incrementor(monthly_requests_count, y_m)
  incrementor(file_frequency, file_request)
  incrementor(statuses, status)
end

#########OUTPUTS########
question_formatter(1)
puts "     There were a total of #{total_requests} requests in the log file."

question_formatter(2)
monthly_requests_a = monthly_requests_count.to_a
puts "     Year-Month        Number of Requests"
puts "     ------------------------------------"
monthly_requests_a.each do |date, requests|
  puts "     #{date}              #{requests}"
end

question_formatter(3)
unsuccessful_requests = (((statuses['404'].to_f+ statuses['403'].to_f)/total_requests)*100)
puts "     #{unsuccessful_requests}% of all requests were unsuccessful (4xx status code)."

question_formatter(4)
redirected_requests = (((statuses['302'].to_f+ statuses['304'].to_f)/total_requests)*100)
puts "     #{redirected_requests}% of all requests were redirected (3xx status code)."

question_formatter(5)
file_frequency_most = largest_hash(file_frequency).to_a.sort
file_frequency_most.each do |file, requests|
  print "     \"#{file}\" was the most wanted file with #{requests} total requests."
end

question_formatter(6)
file_frequency_least = smallest_hash(file_frequency).to_a.sort

#Since multiple files can be tied for first, this gives the user the option of viewing the amount of files least requested (1).
#Or allows viewing the file names in alphabetical order.
if file_frequency_least.length > 100
  puts "     There are over #{file_frequency_least.length} individual files that are tied for least amount of requests.".center(@columns)
  puts "     Would you like to view all of these individual files? (Y/N)\n".center(@columns)
  file_least_response = gets.chomp.upcase
  if file_least_response == 'Y'
    file_frequency_least.each do |file, requests|
      print "#{file}"
      puts
    end
  else
    puts "\n\n     Good call. Not outputting #{file_frequency_least.length} files. \n\n"
  end
  else
  file_frequency_least.each do |file, requests|
    print "#{file} \n"
  end
end

#######FILE-SPLITTER#######
puts "File Splitter".center(@columns, '-')
puts "The log file will now be catorgorized and saved individually.".center(@columns)
puts "The default save location is - '#{splitter_path}'".center(@columns)
puts "\nReady to continue? (Y/N)"
splitter_conf = gets.chomp.upcase

if splitter_conf == 'Y'
  puts "Starting "
  else abort.("OK. Files won't won't be saved").center(@columns)
end

Dir.mkdir(splitter_path) unless File.exists?(splitter_path)
monthly_requests.each do |k,v|
	divided_name = splitter_path + k + '.log'
	File.open(divided_name, "w+") do |write|
		write.puts(v)
	end
end
puts "     \n\nLogs catorgorized by year and month and saved at #{splitter_path}.\n\n"
puts "     Program execution complete. Closing...\n\n".center(@columns)
