# Copyright 2011 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "vertx"
require "set"
include Vertx

Vertx::go do
  HttpServer.new.request_handler do |req|
    req.pause
    filename = (0...9).map { ('A'..'Z').to_a[rand(26)] }.join
    filename << ".uploaded"
    FileSystem::open(filename).handler do |compl|
      pump = Pump.new(req, compl.result.write_stream)
      start_time = Time.now
      req.end_handler do
        compl.result.close.handler do
          end_time = Time.now
          puts "Uploaded #{pump.bytes_pumped} bytes to #{filename} in #{1000 * (end_time - start_time)} ms"
          req.response.end
        end
      end
      pump.start
      req.resume
    end
  end.listen(8080)
end

puts "hit enter to exit"
STDIN.gets