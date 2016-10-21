require 'open-uri'
require 'date'

totals = Hash.new
file_frequency = Hash.new
statuses = Hash.new
daily_requests= Hash.new
monthly_requests = Hash.new
monthly_requests_count = Hash.new
unix_time = []
failure_array = []
_300s = []
_400s = []

remote_file = 'http://s3.amazonaws.com/tcmg412-fall2016/http_access_log'
log_file = 'log_file.txt'
test_file = 'log_file_shortened.txt'
splitter_path = 'logs_by_month/'

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
  puts "".center((columns), "~")+"\n"
end

#Ask user if they'd like to execute the program

puts "\n\n\nBegin parsing? (Y/N)".center(columns)
response = gets.chomp.upcase
if response == "Y" 
  puts "     Downloading log file from " + remote_file + ".\n"
  download = open(remote_file)
  IO.copy_stream(download, log_file)
  puts "     The file " + remote_file + " has been downloaded and saved to your directory.\n"
  else
    puts "     That's fine....\n"
end
#Counts the total number of requests (lines) in the file. 
File.foreach(log_file) {}
total_requests = $.
#Loops through saved file

File.foreach(log_file) do |data|
	delimited = /.*\[(.*) \-[0-9]{4}\] \"([A-Z]+) (.+?)( HTTP.*\"|\") ([2-5]0[0-9]) .*/.match(data)
  if !delimited
    failure_array.push(data)
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

  unless monthly_requests[y_m]
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

if file_frequency_least.length > 1
  puts "     There are over #{file_frequency_least.length} individual files that are tied for least amount of requests.".center(columns)
  puts "     Would you like to view all of these individual files? (Y/N)\n".center(columns)
  file_least_response = gets.chomp.upcase
  if file_least_response == 'Y'
    file_frequency_least.each do |file, requests|
      print "#{file}"
      puts
    end
  else
    puts "     OK. Not printing #{file_frequency_least.length} files." + "\n"
  end
  else
  file_frequency_least.each do |file, requests|
    print "#{file} \n"
  end
end

#######FILE-SPLITTER#######
Dir.mkdir(splitter_path) unless File.exists?(splitter_path)
monthly_requests.each do |k,v|
	divided_name = splitter_path + k + '.log'
	File.open(divided_name, "w+") do |write|
		write.puts(v)
	end
end
puts "Logs catorgorized by year and month and saved at #{splitter_path}.\n\n"
























