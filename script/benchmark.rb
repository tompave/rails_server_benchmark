#!/usr/bin/env ruby

# ---------------------------------------------------------
# Configuration

concurrency_level = 50
seconds = 30
# total_request = 400

tool = :ab
# tool = :siege

if !defined?(seconds) && !defined?(total_request)
  exit "You must either define the duration of the test or the number of requests"
end

# ---------------------------------------------------------
# Benchmarking tools
#
# Here there is a template command to run siege instead of ab.
# This is not truly supported because collecting the output of
# siege is a bit harder.
#
# Apache Bench:
#   stop after 400 requests:
#     ab -c 30 -n 400
#   stop after 30 seconds:
#     ab -c 30 -t 30
#
# Siege:
#   stop after 400 requests:
#     siege -b -c 30 -r 400
#   stop after 30 seconds:
#     siege -b -c 30 -t 30s
#

if tool == :ab
  base_cmd = "ab -r -c #{concurrency_level}"

  if defined?(seconds) && seconds
    base_cmd << " -t #{seconds}"
  elsif defined?(total_request) && total_request
    base_cmd << " -n #{total_request}"
  end
elsif tool == :siege
  base_cmd = "siege -b -c #{concurrency_level}"

  if defined?(seconds) && seconds
    base_cmd << " -t #{seconds}s"
  elsif defined?(total_request) && total_request
    base_cmd << " -r #{total_request}"
  end
end


# ---------------------------------------------------------

endpoints = [
  "/fibonacci/:number", # 0.34 seconds on average on my machine
  "/template-render",
  "/template-render-no-response",
  "/network-io",
  "/network-io-and-render",
  "/pause/:seconds",
  "/pause-and-render/:seconds"
]



@base_url = "http://127.0.0.1:3000"

def url_for(path)
  URI.join(@base_url, path).to_s
end

# ---------------------------------------------------------

require 'uri'

output_file_path = File.expand_path("../../bench_results.txt", __FILE__)
@out_file = File.open(output_file_path, "w")

def log(str)
  @out_file.puts str
  @out_file.puts "\n"
end

# ---------------------------------------------------------

log Time.now.to_s

endpoints.each do |path|
  log "====================================" * 3

  cmd = "#{base_cmd} #{url_for(path)}"

  # suppress the request logging for Siege
  cmd << " 1> /dev/null" if tool == :siege

  puts cmd
  log ">>>  " + cmd

  output = `#{cmd}`
  log output
end

@out_file.close
