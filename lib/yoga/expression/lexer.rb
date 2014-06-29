require "strscan"

module Yoga
  class Expression
    module Lexer

      attr_reader :tokens

      def scan
        @scanner = StringScanner.new(@body)
        @tokens = []

        until @scanner.eos?
          scan_part
        end

        @tokens
      end

      def scan_part
        scan_string     ||
        scan_number     ||
        scan_contain    ||
        scan_identifier ||
        scan_operator   ||
        scan_whitespace ||
        error!
      end

      def scan_number
        if @scanner.scan(/(-?[0-9]+)/)
          tokens << [:NUMBER, @scanner[1]]
        end
      end

      def scan_string
        scan_single_string ||
        scan_double_string
      end

      def scan_single_string
        if @scanner.scan(/'((?:\\'|[^'])+)'/)
          tokens << [:STRING, @scanner[1]]
        end
      end

      def scan_double_string
        if @scanner.scan(/"((?:\\"|[^"])+)"/)
          tokens << [:STRING, @scanner[1]]
        end
      end

      def scan_operator
        if @scanner.scan(/\|/)
          tokens << [:UNION]
        elsif @scanner.scan(/\&/)
          tokens << [:INTERSECT]
        elsif @scanner.scan(/--/)
          tokens << [:SDIFFERENCE]
        elsif @scanner.scan(/-/)
          tokens << [:DIFFERENCE]
        elsif @scanner.scan(/\*/)
          tokens << [:STAR]
        elsif @scanner.scan(/\+/)
          tokens << [:PLUS]
        elsif @scanner.scan(/\?/)
          tokens << [:OPTIONAL]
        elsif @scanner.scan(/\(/)
          tokens << [:LPAREN]
        elsif @scanner.scan(/\)/)
          tokens << [:RPAREN]
        else
          scan_repetition
        end
      end

      def scan_repetition
        if @scanner.scan(/\{([0-9]*)(\,([0-9]*))?\}/)
          tokens << [:REPETITION,
            @scanner[1],
            !!@scanner[2],
            @scanner[3]]
        end
      end

      def scan_contain
        if @scanner.scan(/\[(.*?)\]/)
          tokens << [:CONTAIN, @scanner[1]]
        end
      end

      def scan_identifier
        if @scanner.scan(/([A-Za-z_][A-Za-z0-9_-]*)/)
          tokens << [:IDENTIFIER, @scanner[1]]
        end
      end

      def scan_whitespace
        if @scanner.scan(/\s+/)
          true
        end
      end

      def error!
        start = [@scanner.pos - 8, 0].max
        stop  = [@scanner.pos + 8, @scanner.string.length].min
        snip  = @scanner.string[start..stop].strip
        char  = @scanner.string[@scanner.pos]
        raise SyntaxError, "invalid syntax near `#{snip.inspect}' (#{char.inspect})"
      end

    end
  end
end
