#!/usr/bin/env ruby

require 'csv'

RESULTS_DIR = File.expand_path("../../results", __FILE__)
PROCESSED = File.join(RESULTS_DIR, "processed.csv")
PREFIX = "bench_results_"


def get_server_label(file_name)
  parts = File.basename(file_name, ".csv").sub(PREFIX, "").split("_")

  case parts[0]
  when "unicorn" then parts.join(" x")
  when "puma" then "#{parts[0]} x#{parts[1]}:#{parts[2]}"
  else raise "unrecognized file name: #{file_name}"
  end
end


# [endpoints]
#   [metrics]
#     [servers]
#       [concurrency levels]

@data = Hash.new do |root, endpoint|
  root[endpoint] = Hash.new do |ep, metric|
    ep[metric] = Hash.new do |mt, server|
      mt[server] = []
    end
  end
end

def store(endpoint:, metric:, server:, data:)
  @data[endpoint][metric][server] = data
end

raw_results_files = Dir.glob(RESULTS_DIR + "/" + PREFIX + "*")
concurrency_levels = %w(1 10 20 30 40 50)

raw_results_files.each do |file_path|
  server = get_server_label(file_path)

  CSV.foreach(file_path, headers: true) do |row|
    store(
      endpoint: row["path"],
      metric: row["metric"],
      server: server,
      data: concurrency_levels.map { |c| row.send(:[], c) }
    )
  end
end


out = File.open(PROCESSED, "w")

@data.each_pair do |endpoint, metrics|
  out.puts endpoint
  out.puts ""

  metrics.each_pair do |metric, servers|
    out.puts CSV.generate_line([metric, *concurrency_levels])

    servers.each_pair do |server, data|
      out.puts CSV.generate_line([server, *data])
    end
    out.puts "\n\n"
  end
end

out.close
