require 'socket'
require 'json'

module Chrome
  class Client
    def initialize(host, port)
      @socket = TCPSocket.open(host, port)
      handshake
    end

    def handshake
      str = "ChromeDevToolsHandshake\r\n"
      @socket.write(str)
      if @socket.gets == str
        ;
      else
        raise
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
        Tab.new(self, ary[0].to_i)
      end
    end

    def extension(id)
      ExtensionPorts.new(self, id)
    end
  end

  class Tab
    @@seq = 1

    def initialize(client, number)
      @client = client
      @number = number
    end

    def request(body)
      @client.request({ 'Tool' => 'V8Debugger', 'Destination' => @number },
                      body)
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
      request({ 'command' => 'attach' })
    end

    def debugger_command(command, arguments)
      h, r = request({
                       'command' => 'debugger_command',
                       'data' => {
                         'seq' => @@seq,
                         'type' => 'request',
                         'command' => command,
                         'arguments' => arguments,
                       }
                     })
      @@seq += 1

      return h, r
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
