class BenchmarksController < ApplicationController
  REPO_URL  = URI("https://api.github.com/repos/tompave/rails_server_benchmark")
  FILE_PATH = Rails.root.join("lib/data/mark_twain.txt")


  def noop
    head 200
  end


  def pause
    seconds = params[:seconds].to_i
    sleep(seconds)
    render text: seconds
  end


  def network_io
    time = Benchmark.realtime { Net::HTTP.get(REPO_URL) }
    render text: time.to_s
  end


  def file_io
    time = Benchmark.realtime { File.read(FILE_PATH) }
    render text: time.to_s
  end


  def fibonacci
    number = params[:number].to_i
    time = Benchmark.realtime { fib(number) }
    render text: time.to_s
  end


  def template
    @data = 400.times.map do |i|
      { index: i, message: "item n #{i}" }
    end
  end


  def mix_and_match
    hash = JSON.parse(Net::HTTP.get(REPO_URL), symbolize_names: true)
    list = hash.each_pair.each_with_index.map do |key, value, index|
      { index: index, message: "#{key} => #{value}"}
    end
    @data = list * 10
    render :template
  end


  private


  def fib(n)
    case n
    when 0 then 0
    when 1 then 1
    else
      fib(n - 1) + fib(n - 2)
    end
  end

end
