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
        scan_operator   ||
        scan_string     ||
        scan_number     ||
        scan_character  ||
        scan_whitespace ||
        error!
      end

      def scan_number
        if @scanner.scan(/([0-9]+)/)
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
          tokens << [:STRING, string_escapes(@scanner[1])]
        end
      end

      def scan_operator
        scan \
          /\|/  => :UNION,
          /\$/  => :INTERSECT,
          /--/  => :SDIFFERENCE,
          /-/   => :DIFFERENCE,
          /\*/  => :STAR,
          /\+/  => :PLUS,
          /\?/  => :OPTIONAL,
          /\(/  => :LPAREN,
          /\)/  => :RPAREN,
          /\[/  => :LBRACK,
          /\]/  => :RBRACK,
          /\\"/ => :ESCAPED,
          /\\'/ => :ESCAPED,
          /\^/  => :INVERT,
          /\{/  => :LBRACE,
          /\}/  => :RBRACE,
          />/   => :GREATER,
          /</   => :LESSER,
          /:/   => :COLON,
          /,/   => :COMMA,
          /%/   => :PERCENT,
          /\$/  => :DOLLAR
      end

      def scan_character
        scan /(\\?[A-Za-z_])/ => proc {
          [:CHARACTER, string_escapes(@scanner[1])]
        }
      end

      def scan_whitespace
        if @scanner.scan(/\s+/)
          true
        end
      end

      private

      def scan(hash)
        matched = false
        hash.each do |key, value|
          if @scanner.scan(key)
            v = if value.is_a? Block
              instance_exec(&value)
            else
              value
            end

            matched = true
            tokens << [v].flatten(1)
            break
          end
        end

        yield if !matched and block_given?
        matched
      end

      def error!
        start = [@scanner.pos - 8, 0].max
        stop  = [@scanner.pos + 8, @scanner.string.length].min
        snip  = @scanner.string[start..stop].strip
        char  = @scanner.string[@scanner.pos]
        raise SyntaxError, "invalid syntax near `#{snip.inspect}' (#{char.inspect})"
      end

      def string_escapes(string)
        # "\\\\" => "\\"
        string.gsub(/\\[\\0abtnvfr]/, "\\0" => "\0",
          "\\a" => "\a", "\\b" => "\b", "\\t" => "\t",
          "\\n" => "\n", "\\v" => "\v", "\\f" => "\f",
          "\\r" => "\r").gsub(/\\x([0-9a-f]{2})/) do |num|
          num[2..-1].to_i(16).chr
        end.gsub("\\\\", "\\")
      end

    end
  end
end
