# encoding: utf-8
# frozen_string_literal: true

module Fixtures
  class Scanner
    include Yoga::Scanner

    def self.call(source)
      new(source).call
    end

    def scan
      scan_operators || scan_keywords || scan_identifiers || scan_space ||
        fail("Unexpected token `#{@scanner.string[@scanner.charpos].inspect}`" \
          " at #{location}")
    end

    def scan_operators
      %w(< > = + % - / * ^ ; ( )).inject(false) { |a, e| a || match(e) }
    end

    def scan_keywords
      match(:require)
    end

    def scan_identifiers
      match(/[0-9]+/, :NUMERIC) || match(/[a-zA-Z][a-zA-Z0-9_-]*[!?]?/, :IDENT)
    end

    def scan_space
      match_line || match(/\s+/, false)
    end
  end
end
