# encoding: utf-8
# frozen_string_literal: true

# frozen_string_literal: true
module Yoga
  class Error < ::StandardError; end

  class LocationError < Error
    attr_reader :location
  end

  class ParseError < LocationError; end

  class UnexpectedTokenError < ParseError
    def initialize(expected:, got:, location:)
      @expected = expected
      @got = got
      @location = location
      super(generate_message)
    end

  private

    def generate_message
      "Unexpected #{@got}, expected one of #{@expected.to_a.join(', ')} " \
        "at #{@location}"
    end
  end
end
