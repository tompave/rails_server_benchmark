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


# ---------------------------------------------------------
# Setup the data

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


# ---------------------------------------------------------
# Setup more data

endpoints = @data.keys
metrics = @data.values.first.keys
servers = @data.values.first.values.first.keys

@rotated = Hash.new do |root, concurrency_level|
  root[concurrency_level] = Hash.new do |cl, metric|
    cl[metric] = Hash.new do |mt, endpoint|
      mt[endpoint] = []
    end
  end
end

def rotated_store(concurrency:, metric:, endpoint:, data:)
  @rotated[concurrency][metric][endpoint] = data
end


concurrency_levels.each_with_index do |cl, cl_index|
  metrics.each do |metric|
    endpoints.each do |endpoint|
      data = servers.map do |server|
        @data[endpoint][metric][server][cl_index]
      end
      rotated_store(
        concurrency: cl,
        metric: metric,
        endpoint: endpoint,
        data: data
      )
    end
  end
end

# ---------------------------------------------------------
# Write the new CSV

out = File.open(PROCESSED, "w")

# Y:metric, X:concurrency, data:server

@data.each_pair do |endpoint, metrics|
  out.puts endpoint
  out.puts ""

  metrics.each_pair do |metric, servers|
    out.puts metric
    out.puts CSV.generate_line(["concurrent requests", *concurrency_levels])

    servers.each_pair do |server, data|
      out.puts CSV.generate_line([server, *data])
    end
    out.puts "\n\n"
  end
end

out.puts "----------------------------------"

# Y:metric, X:server, data:endpoint

@rotated.each_pair do |concurrency_level, metrics|
  out.puts concurrency_level
  out.puts ""

  metrics.each_pair do |metric, endpoints|
    out.puts metric
    out.puts CSV.generate_line(["server", *servers])

    endpoints.each_pair do |endpoint, data|
      out.puts CSV.generate_line([endpoint, *data])
    end
    out.puts "\n\n"
  end
end


out.close
