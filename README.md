# Rails Server Benchmark

This is a demo Rails application to benchmark Unicorn and Puma on Ruby MRI with different types of work.

The application implements six actions on `BenchmarksController`:


* `/fibonacci/:number`
  Calculate a fibonacci number, then respond with just the number, as plain text.
* `/template-render`
  Renders a view template with a ERB loop, conditionals and interpolation, responds with the template.
* `/template-render-no-response`
  Like the one above, but it discards the rendered body and responds with the time taken, as plain text.
* `/network-io`
  Execute an HTTP GET, then respond with the time taken.
* `/network-io-and-render`
  Combines `network-io` and `template-render`, to test a mix of CPU and IO work.
* `/pause/:seconds`
  `Kernel#sleep` for a few seconds, then respond with 200 and the number of seconds in the body.
* `/pause-and-render/:seconds`
  Combines `/pause/:seconds` and `template-render`, to test a mix of CPU and (simulated) IO work.

The application does not interact with a DB and the rendered HTMl does not link to any asset.

These endpoints are benchmarked with different configurations of Unicorn and Puma.


# Ruby and server versions

* Ruby MRI 2.3.3
* Unicorn 5.2.0
* Puma 3.6.2

# Run the servers

Example commands to run start the app with the two servers:

## Unicorn

```
RAILS_ENV=production WORKER_COUNT=4 bin/unicorn -c config/unicorn.rb -E production
```

## Puma

```
RAILS_ENV=production WORKER_COUNT=4 THREADS_COUNT=5 bin/puma -C config/puma.rb -e production
```


## How to run the benchmarks (wip)

The application comes with a ruby script to automate the benchmarks: `script/benchmark.rb`.

It runs `ab` and collects the results in a `results/bench_results.csv` file.  
It defaults to running `ab` for 30 seconds, with increasing concurrency levels: 1, 10, 20, 30, 40, 50. It tries its best to sleep between CPU intesive tests to let the processor cool down a little.

Each run takes roughly 25 minutes (`(30 * 6 * 7 + (5 * 6 + 20) * 5) / 60`).

After each run, rename the file by adding the server configuration, e.g. `bench_results_unicorn_4.csv` for Unicorn running with 4 workes, and `bench_results_puma_4_5.csv` for Puma running with 4 workers and 5 threads per worker.

This is necessary to run the next script: `script/organize.rb`.  
This will parse the CSVs and create a new `processed.csv` file with the data grouped in a way that makes it easier to compare how the different setups performed on the same tests.
