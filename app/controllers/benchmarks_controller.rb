class BenchmarksController < ApplicationController
  REMOTE_URL = URI("https://www.facebook.com/")

  def fibonacci
    number = params[:number].to_i
    time = Benchmark.realtime { fib(number) }
    render plain: time.to_s
  end


  def template_render
    @data = 400.times.map do |i|
      { index: i, message: "item n #{i}" }
    end
    render :long_list
  end


  def template_render_no_response
    @data = 400.times.map do |i|
      { index: i, message: "item n #{i}" }
    end
    time = Benchmark.realtime { render_to_string(:long_list) }
    render plain: time.to_s
  end


  def network_io
    time = Benchmark.realtime { Net::HTTP.get(REMOTE_URL) }
    render plain: time.to_s
  end


  def network_io_and_render
    html = Net::HTTP.get(REMOTE_URL)
    list = html.split("\n").each_with_index.map do |str, index|
      { index: index, message: str }
    end
    @data = list * 7
    render :long_list
  end


  def pause
    seconds = params[:seconds].to_i
    sleep(seconds)
    render plain: seconds
  end


  def pause_and_render
    @data = 400.times.map do |i|
      { index: i, message: "item n #{i}" }
    end

    seconds = params[:seconds].to_i
    sleep(seconds)

    render :long_list
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
