class StompPublisher
  class Frame
    class InvalidFrame < Exception
    end

    COMMANDS = %w(
      SEND
      SUBSCRIBE
      UNSUBSCRIBE
      BEGIN
      COMMIT
      ABORT
      ACK
      NACK
      DISCONNECT
      CONNECT
      STOMP
      CONNECTED
      MESSAGE
      RECEIPT
      ERROR
    )

    attr_accessor :command, :header, :body

    def self.parse(frame)
      command = COMMANDS.detect { |cmd| frame =~ /^(#{cmd}\r?\n)/ } or
          raise InvalidFrame.new("invalid or missing command")
      header_start_ndx = $1.length + 1

      header_separator_ndx = frame.index(/(\r?\n\r?\n)/) or
          raise InvalidFrame.new("missing headers")
      body_start_ndx = header_separator_ndx + $1.length

      body_terminator_ndx = frame.rindex(/\0(\r?\n)*/) or
          raise InvalidFrame.new("missing end of body")

      header = Header.parse(frame[(command.length + 1)..(header_separator_ndx - 1)])
      body = frame[body_start_ndx..(body_terminator_ndx - 1)]

      if (content_length = header["content-length"])
        content_length = Integer(content_length) or
            raise InvalidFrame("invalid content-length")

        body.bytesize == content_length or
            raise InvalidFrame("content-length was #{body.bytesize}, expected: #{content_length}")
      end

      Frame.new(command, header, body)
    end

    def initialize(command, header, body = "")
      self.command = command
      self.header = header
      self.body = body
    end

    def body=(body)
      @body = body
      self.header['content-length'] = body.to_s.bytesize
    end

    def to_s
      "#{command}\n#{header}\n\n#{body}\0"
    end
  end
end