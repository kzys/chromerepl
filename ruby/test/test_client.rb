require 'test/unit'
require 'google/chrome/client'
require 'stringio'

class ClientTest < Test::Unit::TestCase
  def test_new
    assert_raise Google::Chrome::HandshakeError do
      Google::Chrome::Client.new(StringIO.new)
    end

    io = StringIO.new("ChromeDevToolsHandshake\r\n" * 2, 'r+')
    assert_kind_of(Google::Chrome::Client.new(io), Google::Chrome::Client)
  end
end
