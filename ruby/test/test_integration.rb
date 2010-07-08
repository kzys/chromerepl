require 'test/unit'
require 'google/chrome/repl'

class IntegrationTest < Test::Unit::TestCase
  def test_github_issue_1
    repl = Google::Chrome::REPL.new(9222, 'kjmomgcillmbndiojpncfjhcmlhhgjeo')
    repl.session do |port|
      assert_equal([{ 'success' => 5 }], repl.post(port, 'x = 5'))
      assert_equal([{ 'success' => 5 }], repl.post(port, 'x'))

      assert_equal([{}], repl.post(port, 'var y = 7'), 'set')
      assert_equal([{ 'success' => 7 }], repl.post(port, 'y'))
    end
  end
end
