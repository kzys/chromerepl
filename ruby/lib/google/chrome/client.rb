#
# = google/chrome/client.rb
#
# "Google Chrome Developer Tools Procotol" client library.
#
# Author:: KATO Kazuyoshi
# License:: X11 License
#

require 'socket'
require 'json'

module Google
  module Chrome
    class HandshakeError < StandardError; end

    class Client

      #
      # Create a Client object and establish the debugger connection.
      #
      def self.open(host, port)
        self.new(TCPSocket.open(host, port))
      end

      def initialize(socket)
        @socket = socket
        handshake
      end

      #
      # Read all responses from the server.
      #
      def read_all_response
        result = []

        while IO.select([ @socket ], [], [], 0.1)
          result << read_response
        end

        result
      end

      #
      # Read one response from the server.
      #
      def read_response
        header = {}

        while ln = @socket.gets
          case ln
          when "\r\n"
            break
          when /^([A-Za-z-]+):(.*)$/
            header[$1] = $2.chomp
          else
            raise
          end
        end

        body = JSON.parse(@socket.read(header['Content-Length'].to_i))
        return header, body
      end

      #
      # Send a request.
      #
      def request(header, body)
        write_request(header, body)
        return read_response
      end

      def server_version
        header, resp = request({ 'Tool' => 'DevToolsService' },
                               { 'command' => 'version' })
        resp['data']
      end

      def tabs
        header, resp = request({ 'Tool' => 'DevToolsService' },
                               { 'command' => 'list_tabs' })
        resp['data'].map do |ary|
          Tab.new(self, ary[0].to_i, ary[1])
        end
      end

      def extension(id)
        ExtensionPorts.new(self, id)
      end

      def handshake
        greeting = "ChromeDevToolsHandshake\r\n"
        @socket.write(greeting)

        s = @socket.gets
        if s == greeting
          ;
        else
          raise HandshakeError, s
        end
      end

      def write_request(header, body)
        str = body.to_json

        header['Content-Length'] = str.length
        header.each_pair do |k, v|
          @socket.write("#{k}:#{v}\r\n")
        end
        @socket.write("\r\n")
        @socket.write(str)
      end
    end

    class Tab
      @@seq = 1

      def initialize(client, number, uri)
        @client = client
        @number = number
        @uri = uri
      end
      attr_reader :number, :uri

      def request(body)
        @client.write_request({ 'Tool' => 'V8Debugger',
                                'Destination' => @number },
                              body)
        @client.write_request({ 'Tool' => 'V8Debugger',
                                'Destination' => @number },
                              { 'command' => 'evaluate_javascript',
                                'data' => 'javascript:void(0);' })

        wait do |resp|
          if resp['data']['type'] == 'response'
            true
          elsif resp['data']['event'] == 'afterCompile'
            false
          else
            false
          end
        end
      end

      def wait(&block)
        loop do
          h, resp = @client.read_response
          if resp['command'] == 'debugger_command'
            return resp if block.call(resp)
          else
            return resp
          end
        end
      end

      def attach
        request({ 'command' => 'attach' })
        return unless block_given?

        begin
          yield
        ensure
          detach
        end
      end

      def detach
        request({ 'command' => 'detach' })
      end

      def debugger_command(command, arguments = {})
        resp = request({
                         'command' => 'debugger_command',
                         'data' => {
                           'seq' => @@seq,
                           'type' => 'request',
                           'command' => command,
                           'arguments' => arguments,
                         }
                       })
        @@seq += 1

        return resp
      end

      def scripts
        debugger_command('scripts')['data']['body']
      end
    end

    class ExtensionPorts
      def initialize(client, id)
        @client = client
        @id = id
      end

      def connect
        h, r = @client.request({ 'Tool' => 'ExtensionPorts' },
                               { 'command' => 'connect',
                                 'data' => { 'extensionId' => @id } })
        port = r['data']['portId'].to_i

        if block_given?
          begin
            yield(port)
          ensure
            disconnect(port)
          end
        else
          return port
        end
      end

      def disconnect(port)
        @client.request({ 'Tool' => 'ExtensionPorts', 'Destination' => port },
                        { 'command' => 'disconnect' })
      end

      def post(port, data)
        @client.request({ 'Tool' => 'ExtensionPorts', 'Destination' => port },
                        { 'command' => 'postMessage',
                          'data' => data })
      end
    end
  end
end
