# encoding: utf-8
# frozen_string_literal: true

module Yoga
  # An error originating from the Yoga class.  All behavior here is private
  # to the Yoga module.
  #
  # @api private
  # @private
  class Error < ::StandardError
    # Initialize the error.
    #
    # @api private
    def initialize(data)
      data.each { |k, v| instance_variable_set(:"@#{k}", v) }
      super(generate_message)
    end

  private

    # Generates a message for the exception.
    #
    # @return [::String]
    def generate_message
      message
    end
  end

  # An error that has a corresponding location information.
  #
  # @api private
  class LocationError < Error
    attr_reader :location
  end

  # An error that occurred with parsing.
  #
  # @api private
  class ParseError < LocationError; end

  # An unexpected token was encountered while parsing.
  #
  # @api private
  class UnexpectedTokenError < ParseError
    # (see Error#generate_message)
    private def generate_message
      "Unexpected #{@got}, expected one of #{@expected.to_a.join(', ')} " \
        "at #{@location}"
    end
  end

  # A shift was requested, but was invalid.
  #
  # @api private
  class InvalidShiftError < ParseError
    # (see Error#generate_message)
    private def generate_message
      "Parser shifted, but no tokens remain at #{@location}"
    end
  end
end
