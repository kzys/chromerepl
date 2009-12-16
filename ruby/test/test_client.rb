require 'test/unit'
require 'google/chrome/client'

class ClientTest < Test::Unit::TestCase
  def test_new
    assert_raise ArgumentError do
      Google::Chrome::Client.new
    end
  end
end
