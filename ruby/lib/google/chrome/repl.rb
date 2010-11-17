require 'google/chrome/client'
require 'readline'
require 'pp'

module Google
  module Chrome
    class REPL
      def create_client(port)
        Google::Chrome::Client.open('localhost', port)
      end

      def initialize(port, extension_id)
        @client = create_client(port)
        @extension = @client.extension(extension_id)
      end


      def print_log_and_error(data)
        if data['error']
          puts data['error']['stack']
        elsif data['log']
          if data['log'].kind_of?(String)
            puts data['log']
          else
            pp data['log']
          end
        end
      end

      def print_response(data)
        if data.empty?
          puts 'nil'
        elsif data['success']
          pp data['success']
        else
          print_log_and_error(data)
        end
      end

      def eval_string(script, argv)
        s = "(function () { #{script}; }).apply(null, #{argv.to_json})"

        @extension.connect do |port|
          @extension.post(port, s)
          @client.read_all_response.each do |header, resp|
            print_log_and_error(resp['data'])
          end
        end
      end

      def eval_file(path, argv)
        open(path) do |f|
          eval_string(f.read, argv)
        end
      end

      def post(port, ln)
        @extension.post(port, ln)
        @client.read_all_response.map do |header, resp|
          resp['data']
        end
      end

      def session(&block)
        @extension.connect do |port|
          block.call(port)
        end
      end

      def interactive_with_extension(port)
        while ln = Readline.readline('> ', true)
          @extension.post(port, ln)
          @client.read_all_response.each do |header, resp|
            print_response(resp['data'])
          end
        end
        @extension.disconnect(port)
      end

      def interactive_with_tab(tab)
        tab.attach

        while ln = Readline.readline('> ', true)
          resp = tab.debugger_command('evaluate',
                                      { 'expression' => ln, 'global' => true })
          if resp['data']['command'] == 'evaluate'
            pp resp['data']['body']['value']
          end
        end

        tab.detach
      end

      def interactive(attach)
        puts "Protocol version: %s" % @client.server_version

        tab = nil

        if attach
          tab = @client.tabs.find do |t|
            t.number == attach
          end

          if tab
            interactive_with_tab(tab)
          else
            $stderr.puts("Failed to attach tab (number = #{attach}).")
          end
        else
          port = nil
          begin
            port = @extension.connect
            interactive_with_extension(port)
          rescue ConnectionError
            $stderr.puts('Failed to connect ChromeRepl extension.')
          end
        end
      end

      def print_tabs
        @client.tabs.each do |t|
          printf("%2d %s\n", t.number, t.uri)
        end
      end
    end
  end
end
