# Rails Server Benchmark

This is a demo Rails application to benchmark Unicorn and Puma on Ruby MRI with different types of work.

The application implements five actions on `BenchmarksController`:

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

These endpoints are benchmarked with different configurations of Unicorn and Puma.


# Ruby and server versions

* Ruby MRI 2.3.3
* Unicorn 5.2.0
* Puma 3.6.2

# Hardware

2013 MacBook Pro, 2.7 GHz Intel Core i7, 16 GB RAM.
