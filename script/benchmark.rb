#!/usr/bin/env ruby

# ---------------------------------------------------------
# Configuration

seconds = 5
# total_request = 400
CONCURRENCY_LEVELS = [1, 10, 20, 30, 40, 50]


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

@base_cmd = "ab -r -c %{concurrency_level}"

if defined?(seconds) && seconds
  @base_cmd << " -t #{seconds}"
elsif defined?(total_request) && total_request
  @base_cmd << " -n #{total_request}"
end

@base_cmd << " %{url}"

# ---------------------------------------------------------
def blank?(str)
  str.nil? || str.strip.empty?
end
# ---------------------------------------------------------

ENDPOINTS = [
  "/fibonacci/32", # 0.34 seconds on average on my machine
  "/template-render",
  "/template-render-no-response",
  "/network-io",
  "/network-io-and-render",
  "/pause/2",
  "/pause-and-render/2"
]



BASE_URL = "http://127.0.0.1:3000"

def url_for(path)
  URI.join(BASE_URL, path).to_s
end

# ---------------------------------------------------------

require 'uri'
require 'csv'

output_file_path = File.expand_path("../../bench_results.txt", __FILE__)
@out_file = File.open(output_file_path, "w")

def log(str)
  @out_file.puts str
  @out_file.puts "\n"
end

def write_row(target, type, results)
  str = CSV.generate_line([target, type, *results])
  @out_file.puts str
end
# ---------------------------------------------------------




# ---------------------------------------------------------

REQ_P_S_REGEX = %r{Requests per second\:\s+(\d+\.\d*) \[\#\/sec\] \(mean\)}
T_P_REQ_REGEX = %r{Time per request\:\s+(\d+\.\d*) \[ms\] \(mean\)}
def extract_data(str)
  return nil if blank?(str)
  req_p_s = REQ_P_S_REGEX.match(str)&.[](1).to_s
  t_p_req = T_P_REQ_REGEX.match(str)&.[](1).to_s
  [req_p_s, t_p_req]
end

# ---------------------------------------------------------


@results = {
  req_p_sec: {},
  resp_time: {}
}

def run_test(conc_requests, target)
  cmd = sprintf(@base_cmd, concurrency_level: conc_requests, url: target)
  print ">>> #{cmd}"
  output = `#{cmd}`
end


write_row("path", "metric", CONCURRENCY_LEVELS)

ENDPOINTS.each do |path|
  target = url_for(path)
  req_p_s_results = []
  resp_time_results = []

  CONCURRENCY_LEVELS.each do |conc_req|
    results = run_test(conc_req, target)
    req_p_s, resp_time = extract_data(results)

    puts "  req/s: #{req_p_s}, resp time: #{resp_time}"

    req_p_s_results << req_p_s
    resp_time_results << resp_time
  end

  write_row(path, "req/s", req_p_s_results)
  write_row(path, "resp_time", resp_time_results)
end


@out_file.close
