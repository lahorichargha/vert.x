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

require 'test/unit'
require 'vertx'
require 'utils'
include Vertx

class TimerTest < Test::Unit::TestCase

  def test_one_off

    latch = Utils::Latch.new(1)

    Vertx::go {
      Vertx::set_timer(10) { |timer_id|
        latch.countdown
      }
    }

    assert(latch.await(5))
  end

  def test_periodic

    fires = 10

    latch = Utils::Latch.new(1)

    Vertx::go {
      count = 0
      Vertx::set_periodic(10) { |timer_id|
        count += 1
        if count == fires
          Vertx::cancel_timer(timer_id)
          latch.countdown
        elsif count > fires
          assert(false, 'Fired too many times')
        end
      }
    }

    #Sleep a little bit in case it fires again - wanna make sure it doesn't fire too much
    sleep(0.25)

    assert(latch.await(5))
  end

end
