# Rails Server Benchmark

This is a demo Rails application to benchmark Unicorn and Puma on Ruby MRI with different types of work.

The application implements six actions on `BenchmarksController`:

* `#noop` (`GET /noop`)  
  Just respond with 200, no body.
* `#pause` (`GET /pause/:seconds`)  
  `Kernel#sleep` for a few seconds, then respond with 200 and the number of seconds in the body.
* `#network_io` (`GET /network-io`)  
  Execute an HTTP GET to the GitHub API to obtain JSON data for this repository, then respond with 200 and the time taken.
* `#file_io` (`GET /file-io`)  
  Read a `txt` file from the file system, then respond with 200 and the time taken.
* `#fibonacci` (`GET /fibonacci/:number`)  
  Calculate a fibonacci number, then respond with 200 and the time taken.
* `#template` (`GET /template`)  
  Responds with 200 and renders a view template with a ERB loop, conditionals and interpolation.

The application does not interact with a DB and the rendered HTMl does not link to any asset.

These endpoints are benchmarked with different configurations of Unicorn and Puma.


# Ruby and server versions

* Ruby MRI 2.3.3
* Unicorn 5.2.0
* Puma 3.6.2

# Run the servers

## Unicorn

```
RAILS_ENV=production WORKER_COUNT=4 bin/unicorn -c config/unicorn.rb -E production
```

## Puma

```
RAILS_ENV=production WORKER_COUNT=4 THREADS_COUNT=5 bin/puma -C config/puma.rb -e production
```


## How to run the benchmarks (wip)

The application comes with a ruby script to automate the benchmarks:

```
script/benchmark.rb
```

It runs `ab` and collects the results on a `bench_results.txt` file.  
At the top of the file you can customize the concurrency leve, the number of requests or the duration of the test.

It contains template commands to use `siege` instead of `ab`, but `siege` makes it a bit harder to isolate the test results from the request logging, thus it's not trully supported. At the moment the script is written to work only with `ab`. The `siege` template commands are valid though, and can be used to run independend tests.


