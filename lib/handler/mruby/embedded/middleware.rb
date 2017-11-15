# Copyright (c) 2017 Ichito Nagata, Fastly, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

module H2O

  class App
    def initialize(reprocess)
      @reprocess = reprocess
    end
    def call(env)
      _h2o_middleware_call(env, @reprocess)
    end
  end

  def self.next
    @@next ||= App.new(false)
  end
  def self.reprocess
    @@next ||= App.new(true)
  end

  class AppInputStream
    def initialize
      @chunks = []
      @finished = false
    end
    def each
      loop do
        while c = @chunks.shift
          yield c
        end
        break if @finished
        _h2o_middleware_wait_chunk(self)
      end
    end
    def join
      s = ""
      each do |c|
        s << c
      end
      s
    end
  end
end
