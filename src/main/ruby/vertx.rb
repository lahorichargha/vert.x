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

include Java

require 'core/global_handlers'
require 'core/timers'
require 'core/buffer'
require 'core/file_system'
require 'core/http'
require 'core/net'
require 'core/parsetools'
require 'core/streams'
require 'core/shared_data'
require 'core/std_io'
require 'core/composition'
require 'core/logger'

require 'addons/redis'

# The Vertx modules defines the top level namespace within which all Vertx classes are found.
#
# This module also contains some class methods used for such things as setting and cancelling timers and
# global event handlers, amongst other things.
#
# @author {http://tfox.org Tim Fox}
module Vertx

  # @private
  class TheMain < org.vertx.java.core.VertxMain

    def initialize(block)
      super()
      @block = block
    end

    def go
      @block.call
    end

  end

  # Runs a block in an event loop. The event loop will be chosen from all available loops by the system.
  # Most vert.x operations have to be run in an event loop, so this method is usually used at the beginning of your
  # script to start things running.
  # This method will accept either a Proc or a block.
  # @param [Proc] proc a Proc to run
  # @param [Block] block a block to run.
  def Vertx.go(proc = nil, &block)
    block = proc if proc
    TheMain.new(block).run
  end

  # @private
  class InternalAction < org.vertx.java.core.BlockingAction

    # @private
    def initialize(hndlr)
      super()
      @action = hndlr
    end

    def action
      @action.call
    end
  end

  # Sometimes it is necessary to perform operations in vert.x which are inherently blocking, e.g. talking to legacy
  # blocking APIs or libraries. This method allows blocking operations to be executed cleanly in an asychronous
  # environment.
  # This method will execute the proc or block on a thread from a
  # background thread pool specially reserved for blocking operations. This means the event loop threads are not
  # blocked and can continue to service other requests.
  def Vertx.run_blocking(proc = nil, &block)
    block = proc if proc
    ia = InternalAction.new(block)
    ia.execute
    Future.new(ia)
  end

end