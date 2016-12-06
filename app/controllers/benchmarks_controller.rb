class BenchmarksController < ApplicationController
  REMOTE_URL = URI("https://www.facebook.com/")
  FILE_PATH = Rails.root.join("lib/data/mark_twain.txt")


  def noop
    head 200
  end


  def pause
    seconds = params[:seconds].to_i
    sleep(seconds)
    render plain: seconds
  end


  def network_io
    time = Benchmark.realtime { Net::HTTP.get(REMOTE_URL) }
    render plain: time.to_s
  end


  def file_io
    time = Benchmark.realtime { File.read(FILE_PATH) }
    render plain: time.to_s
  end


  def fibonacci
    number = params[:number].to_i
    time = Benchmark.realtime { fib(number) }
    render plain: time.to_s
  end


  def template
    @data = 400.times.map do |i|
      { index: i, message: "item n #{i}" }
    end
  end


  def mix_and_match
    html = Net::HTTP.get(REMOTE_URL)
    @data = html.split.each_with_index.map do |str, index|
      { index: index, message: str }
    end
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
