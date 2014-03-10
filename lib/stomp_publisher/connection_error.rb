class StompPublisher
  class ConnectionError < Exception
    attr_accessor :frame

    def initialize(msg, frame)
      super(msg)
      self.frame = frame
    end
  end
end