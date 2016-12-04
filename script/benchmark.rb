#!/usr/bin/env ruby

# ---------------------------------------------------------
# Configuration

concurrency_level = 30
seconds = 3
total_request = 400

tool = :ab
# tool = :siege

# ---------------------------------------------------------
# Benchmarking tools

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
ab_cmd =    "ab -c #{concurrency_level} -t #{seconds}"
siege_cmd = "siege -b -c #{concurrency_level} -t #{seconds}s"
# ab_cmd =    "ab -c #{concurrency_level} -n #{total_request}"
# siege_cmd = "siege -b -c #{concurrency_level} -r #{total_request}"


base_cmd = tool == :ab ? ab_cmd : siege_cmd



# ---------------------------------------------------------

endpoints = [
  "/noop",
  "/pause/2",
  "/network-io",
  "/file-io",
  "/fibonacci/32", # 0.34 seconds on average
  "/template",
  "/mix-and-match"
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

  puts cmd
  log cmd

  output = `#{cmd}`
  log output
end

@out_file.close
