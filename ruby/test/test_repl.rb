require 'test/unit'
require 'google/chrome/repl'

class REPLTest < Test::Unit::TestCase
  def test_new
    app = Google::Chrome::REPL.new
    assert_kind_of(app, Google::Chrome::REPL)
  end
end
