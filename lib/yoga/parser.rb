# encoding: utf-8
# frozen_string_literal: true

require "yoga/parser/helpers"

module Yoga
  # A parsing helper.
  #
  # This uses the `@tokens` and `@_root` instance variables.
  module Parser
    # Initialize the parser.
    #
    # @param tokens [::Enumerable<Yoga::Token>]
    def initialize(tokens)
      @tokens = tokens
      @buffer = []
    end

    # Performs the parsing.
    #
    # @return [Yoga::Node]
    def call
      @_root ||= parse_root
    end

    # Internal ruby construct.
    #
    # @private
    # @api private
    def self.included(base)
      base.send :include, Parser::Helpers
    end
  end
end
