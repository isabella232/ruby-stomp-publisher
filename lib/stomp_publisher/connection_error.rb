class StompPublisher
  class ConnectionError < Exception
    attr_accessor :frame

    def initialize(msg, frame)
      self.frame = frame
      if (frame && frame.command == "ERROR" && !frame.body.nil? && frame.body.length > 0)
        msg = "%s: %s" % [ msg, frame.body ]
      end

      super(msg)
    end
  end
end