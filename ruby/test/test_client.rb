require 'test/unit'
require 'google/chrome/client'
require 'stringio'

class FakeIO
  def initialize(*args)
    @io = StringIO.new(args.join(''), 'r')
  end

  def write(s)
    ;
  end

  def gets
    @io.gets
  end

  def read(size)
    @io.read(size)
  end
end

class ClientTest < Test::Unit::TestCase
  def test_new
    assert_raise Google::Chrome::HandshakeError do
      Google::Chrome::Client.new(FakeIO.new)
    end

    io = FakeIO.new("ChromeDevToolsHandshake\r\n")
   assert_kind_of(Google::Chrome::Client, Google::Chrome::Client.new(io))
  end

  def test_request
    io = FakeIO.new("ChromeDevToolsHandshake\r\n",
                    "Content-Length:2\r\n",
                    "\r\n",
                    "{}")
    client = Google::Chrome::Client.new(io)
    header, resp = client.request({}, {})
    assert_equal(header, { 'Content-Length' => '2' })
    assert_equal(resp, {})
  end
end
