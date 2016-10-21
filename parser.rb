require 'open-uri'
require 'date'

totals = Hash.new
file_frequency = Hash.new
statuses = Hash.new
daily_requests= Hash.new
monthly_requests = Hash.new
unix_time = []
failure_array = []

remote_file = 'http://s3.amazonaws.com/tcmg412-fall2016/http_access_log'
local_file = 'log_file.txt'
test_file = 'log_file_shortened.txt'
pad = '     '
extra_pad = '         '

def winsize
  require 'io/console'
  IO.console.winsize
  rescue LoadError
  [Integer(`tput li`), Integer(`tput co`)]
end
rows, columns = winsize

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
def question_formatter(q_num)
  rows, columns = winsize
  puts "\n\nQuestion #{q_num}".center(columns)
  puts "".center((columns), "~")+"\n\n"
end

#Ask user if they'd like to download the file/confirms execution of program
puts 'Would you like to retrieve the file for parsing? (Y/N)'.center(columns)
response = gets.chomp.upcase
if response == "Y" 
  puts "     Downloading log file from " + remote_file + ".\n"
  download = open(remote_file)
  IO.copy_stream(download, local_file)
  puts "     The file " + remote_file + " has been downloaded and saved to your directory.\n"
  else
    puts "     Then why are you here?\n"
end
#Counts the total number of requests (lines) in the file. 
File.foreach(test_file) {}
total_requests = $.
#Loops through saved file
File.foreach(test_file) do |x|
	delimited = /.*\[(.*) \-[0-9]{4}\] \"([A-Z]+) (.+?)( HTTP.*\"|\") ([2-5]0[0-9]) .*/.match(x)
  if !delimited
    failure_array.push(x)
    next
  end
	# Collect groups from #{delimited} and organize the into arrays
	full_date = Time.strptime(delimited[1], '%d/%b/%Y:%H:%M:%S')
	y_m = full_date.strftime('%Y-%m')
  #y_m_d = []                         Include this later?
  unix_time = full_date.to_i
	request = delimited[2]
	file_request = delimited[3]
	status = delimited[5]
  #
  incrementor(monthly_requests, y_m)
  incrementor(file_frequency, file_request)
  incrementor(statuses, status)

end

                          #########OUTPUTS########
question_formatter(1)
puts "     There were a total of #{total_requests} requests in the log file."

question_formatter(2)
monthly_requests_a = monthly_requests.to_a
puts "     Year-Month        Number of Requests"
puts "     ------------------------------------"
monthly_requests_a.each do |date, requests|
  puts "     #{date}              #{requests}"
end

question_formatter(3)
unsuccessful_requests = (((statuses['404'].to_f+ statuses['403'].to_f)/total_requests)*100)
puts unsuccessful_requests

question_formatter(4)
percentage_300s = ((_300s.to_f/total_requests.to_f)*100)
puts "     A total of #{_300s} requests, or #{percentage_300s}%, were redirected."

def request_types_sum(hash)
  hash.each do |status, frequency|
    if status[0] == '3' then _300s += 1 end
    if status[0] == '4' then _400s += 1 end
  end
end

puts request_types_sum(statuses)

question_formatter(5)
puts largest_hash(file_frequency)
puts largest_hash(file_frequency).length

question_formatter(6)
file_frequency_least = smallest_hash(file_frequency).to_a.sort

if file_frequency_least.length > 100
  puts "     There are over #{file_frequency_least.length} individual files that have been requested only once."
  puts "     Would you like to view all of these individual files?" + "\n\n"
  file_least_response = gets.chomp.upcase
  if file_least_response == 'Y'
    file_frequency_least.each do |file, requests|
      print "#{file}"
      puts
    end
  else
    puts "          OK. Not printing #{file_frequency_least.length} files." + "\n\n"
  end
  else
  file_frequency_least.each do |file, requests|
    print "#{file} "
    puts
  end
end
