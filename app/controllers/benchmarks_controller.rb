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
