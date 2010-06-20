require 'readline'
require 'pp'

module Google
  module Chrome
    class REPL
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

      def run(client, extension, script)
        extension.connect do |port|
          if script
            extension.post(port, script)
            client.read_all_response.each do |header, resp|
              print_log_and_error(resp['data'])
            end
          else
            puts "Protocol version: %s" % client.server_version
            while ln = Readline.readline('> ', true)
              extension.post(port, ln)
              client.read_all_response.each do |header, resp|
                print_response(resp['data'])
              end
            end
          end
        end
      end
    end
  end
end
