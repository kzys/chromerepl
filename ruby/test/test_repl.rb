require 'test/unit'
require 'google/chrome/repl'

class Extension
end

class Client
  def initialize(port)
  end

  def extension(id)
    Extension.new
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
end
