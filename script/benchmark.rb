#!/usr/bin/env ruby

# ---------------------------------------------------------
# Configuration

seconds = 30
# total_requests = 400
CONCURRENCY_LEVELS = [1, 10, 20, 30, 40, 50]


if !defined?(seconds) && !defined?(total_requests)
  exit "You must either define the duration of the test or the number of requests"
end

# ---------------------------------------------------------
# Benchmarking tools
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
elsif defined?(total_requests) && total_requests
  @base_cmd << " -n #{total_requests}"
end

@base_cmd << " %{url} 2> /dev/null"

# ---------------------------------------------------------
def blank?(str)
  str.nil? || str.strip.empty?
end
# ---------------------------------------------------------

# Alternate CPU intensive and IO intesive jobs, otherwise
# my CPU will catch fire
#
ENDPOINTS = [
  "/fibonacci/32", # 0.34 seconds on average on my machine
  "/pause/2",
  "/template-render",
  "/network-io",
  "/template-render-no-response",
  "/network-io-and-render",
  "/pause-and-render/2"
]


BASE_URL = "http://127.0.0.1:3000"

require 'uri'

def url_for(path)
  URI.join(BASE_URL, path).to_s
end

# ---------------------------------------------------------

require 'csv'

output_file_path = File.expand_path("../../bench_results.txt", __FILE__)
@out_file = File.open(output_file_path, "w")

# def log(str)
#   @out_file.puts str
#   @out_file.puts "\n"
# end

def write_row(target, type, results)
  str = CSV.generate_line([target, type, *results])
  @out_file.puts str
end


REQ_P_S_REGEX = %r{Requests per second\:\s+(\d+\.\d*) \[\#\/sec\] \(mean\)}
T_P_REQ_REGEX = %r{Time per request\:\s+(\d+\.\d*) \[ms\] \(mean\)}

def extract_data(str)
  return nil if blank?(str)
  req_p_s = REQ_P_S_REGEX.match(str)&.[](1).to_s
  t_p_req = T_P_REQ_REGEX.match(str)&.[](1).to_s
  [req_p_s, t_p_req]
end


def run_test(conc_requests, target)
  cmd = sprintf(@base_cmd, concurrency_level: conc_requests, url: target)
  print cmd
  output = `#{cmd}`
end

def maybe_cooldown(path, seconds)
  if path =~ /fibonacci|render/
    puts "cooling down for #{seconds}s..."
    sleep seconds
  end
end

write_row("path", "metric", CONCURRENCY_LEVELS)

ENDPOINTS.each do |path|
  target = url_for(path)
  req_p_s_results = []
  resp_time_results = []

  CONCURRENCY_LEVELS.each do |conc_req|
    results = run_test(conc_req, target)
    req_p_s, resp_time = extract_data(results)

    puts " | req/s: #{req_p_s}, resp ms: #{resp_time}"

    req_p_s_results << req_p_s
    resp_time_results << resp_time
    maybe_cooldown(path, 5)
  end

  write_row(path, "req/s", req_p_s_results)
  write_row(path, "resp_time", resp_time_results)
  maybe_cooldown(path, 20)
end


@out_file.close
