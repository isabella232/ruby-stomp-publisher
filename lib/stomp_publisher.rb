require 'stomp_publisher/frame'
require 'stomp_publisher/header'
require 'stomp_publisher/connection_error'

require 'tcp_timeout'
require 'securerandom'

class StompPublisher
  FRAME_READ_SIZE = 8192
  MAX_FRAME_SIZE = 65536

  def initialize(host: "localhost", port: 61613, login: nil, passcode: nil, vhost: host, **socket_args)
    @host = host
    @port = port
    @login = login or raise ArgumentError.new("missing argument login")
    @passcode = passcode or raise ArgumentError.new("missing argument passcode")
    @vhost = vhost
    @socket_args = socket_args
  end

  def publish(queue, message, **properties)
    socket = TCPTimeout::TCPSocket.new(@host, @port, **@socket_args)
    connect(socket, @login, @passcode, @vhost)
    send(socket, message, properties.merge(destination: "/queue/#{queue}"))
  end

  protected
    def connect(socket, login, passcode, vhost)
      header = Header.new(
        login: login,
        passcode: passcode,
        host: vhost,
        "accept-version" => "1.2"
      )
      frame = Frame.new("CONNECT", header)
      socket.write(frame.to_s)

      response_frame = read_frame(socket)
      if (response_frame.command != "CONNECTED")
        raise ConnectionError.new("Failed to login: #{response_frame.body}", response_frame)
      end
    end

    def send(socket, message, receipt_id: SecureRandom.hex(16), **properties)
      frame = Frame.new("SEND", Header.new(properties.merge(receipt: receipt_id)), message)
      socket.write(frame.to_s)

      response_frame = read_frame(socket)
      if (response_frame.command != "RECEIPT")
        raise ConnectionError.new("Did not receive expected receipt", response_frame)
      elsif ((response_receipt = response_frame.header["receipt-id"]) != receipt_id)
        raise ConnectionError.new("Received unexpected receipt id: #{response_receipt}", response_frame)
      end

      receipt_id
    end

    def read_frame(socket)
      response = ""
      begin
        response << socket.readpartial(FRAME_READ_SIZE)
        if (response.bytesize > MAX_FRAME_SIZE)
          raise ConnectionError.new("Frame was larger than the max size of #{MAX_FRAME_SIZE}", nil)
        end
        Frame.parse(response)
      rescue Frame::InvalidFrame
        retry
      end
    end
end