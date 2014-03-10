require 'net/http'

class StompPublisher
  class Header
    include Net::HTTPHeader

    ESCAPES = {
      "\\" => "\\\\",
      "\r" => "\\r",
      "\n" => "\\n",
      ":"  => "\\c",
    }

    def self.parse(header_text)
      header = self.new
      header_text.each_line do |line|
        header.add_field(*line.chomp.split(":", 2))
      end
      header
    end

    def initialize(headers = {})
      initialize_http_header(headers)
    end

    def to_s
      each_name.flat_map do |key|
        get_fields(key).map { |value| "#{encode(key)}:#{encode(value)}" }
      end * "\n"
    end

    def encode(value)
      ESCAPES.inject(value.to_s) { |value, (from, to)| value.gsub(from, to) }
    end

    def decode(value)
      ESCAPES.inject(value.to_s) { |value, (from, to)| value.gsub(to, from) }
    end
  end
end