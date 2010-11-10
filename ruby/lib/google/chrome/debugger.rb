require 'google/chrome/client'
require 'readline'
require 'pp'

module Google
  module Chrome
    class Debugger
      def create_client(port)
        Google::Chrome::Client.open('localhost', port)
      end

      def initialize(port)
        @client = create_client(port)
      end

      def prompt(tab = nil)
        s = if tab
              '%4d > ' % [ tab.number ]
            else
              '---- > '
            end
        Readline.readline(s, true)
      end

      def interactive
        tab = nil

        while ln = prompt(tab)
          case ln
          when 'tabs'
            str = @client.tabs.map do |t|
              '%4d: %s' % [ t.number, t.uri ]
            end.join("\n")

            puts str
          when /^attach\s+(\d+)$/
            tab = @client.tabs.find do |t|
              t.number == $1.to_i
            end

            if tab
              tab.attach
            else
              puts 'Failed to find a tab.'
            end
          when 'detach'
            tab.detach
            tab = nil
          when 'scripts'
            str = tab.scripts.map do |s|
              '%4d: %s' % [ s['id'], s['name'] ]
            end.sort.join("\n")

            puts str
          when /^break (.+?):(\d+)/
            path = $1
            line = $2.to_i

            script = tab.scripts.find do |s|
              s['name'] =~ /#{Regexp.quote(path)}$/
            end

            if script
              pp tab.debugger_command('setbreakpoint',
                                      { 'type' => 'script',
                                        'target' => script['name'],
                                        'line' => line })
            else
              puts 'Failed to find a script.'
            end
          else
            pp tab.debugger_command(ln)
          end
        end
      end
    end
  end
end
