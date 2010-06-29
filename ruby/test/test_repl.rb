require 'test/unit'
require 'minitest/mock'
require 'google/chrome/repl'

class Extension < MiniTest::Mock
  def connect(&block)
    block.call(0)
  end
end

class Client
  def initialize(port)
  end

  def read_all_response
    []
  end

  @@extension = nil

  def extension(id)
    Client.extension
  end

  def self.extension=(e)
    @@extension = e
  end

  def self.extension
    @@extension ||= Extension.new
    @@extension
  end
end

class TestableREPL < Google::Chrome::REPL
  def create_client(port)
    Client.new(port)
  end
end

class REPLTest < Test::Unit::TestCase
  def test_new
    app = TestableREPL.new(nil, nil)
    assert_kind_of(app, Google::Chrome::REPL)
  end

  def test_eval_string
    s = '(function () { 1+arguments[0]; }).apply(null, [2])'
    Client.extension.expect('post', nil, [0, s])

    app = TestableREPL.new(nil, nil)
    app.eval_string('1+arguments[0]', [2])

    Client.extension.verify
  end
end
