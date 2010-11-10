require 'test/unit'
require 'google/chrome/repl'

class IntegrationTest < Test::Unit::TestCase
  def test_github_issue_1
    extension_id = ENV['extension_id']
    return unless extension_id

    repl = Google::Chrome::REPL.new(9222, extension_id)
    repl.session do |port|
      assert_equal([{ 'success' => 5 }], repl.post(port, 'x = 5'))
      assert_equal([{ 'success' => 5 }], repl.post(port, 'x'))

      assert_equal([{}], repl.post(port, 'var y = 7'), 'set')
      assert_equal([{ 'success' => 7 }], repl.post(port, 'y'))
    end
  end

  def test_debugger_command
    client = Google::Chrome::Client.open('localhost', 9222)
    tab = client.tabs.first

    tab.attach do
      assert('backtrace', tab.debugger_command('backtrace')['success'])
    end
  end
end
