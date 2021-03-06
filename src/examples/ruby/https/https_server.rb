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
include Vertx

Vertx::go do
  server = HttpServer.new
  server.ssl = true
  server.key_store_path = "server-keystore.jks"
  server.key_store_password = "wibble"

  server.request_handler do |req|
    req.response.chunked = true
    req.response.write_str("<html><body><h1>Hello from vert.x over HTTPS!</h1></body></html>", "UTF-8").end
  end.listen(4443)
end

puts "hit enter to exit"
STDIN.gets