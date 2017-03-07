# encoding: utf-8
# frozen_string_literal: true

module Yoga
  # A token that is used in scanning.  This is emitted when a lexical
  # structure is encountered; e.g., for a `{`.
  class Token
    # The kind of the token.  For any explicit matches (e.g. `"{"`),
    # this is the exact match (e.g. `:"{"`).  For any regular matches
    # (e.g. an identifier), this is in all caps (e.g. `:IDENTIFIER`).
    #
    # @return [::Symbol]
    attr_reader :kind

    # The lexeme that this token is associated.  This is what the token
    # matched directly from the source.
    #
    # @return [::String]
    attr_reader :value

    # The exact location the token was taken from.  This only spans one
    # line.
    #
    # @return [Location]
    attr_reader :location

    # A "hash" of the token.  This is a number that is meant to roughly
    # represent the value of this token.  Used primarily for the Hash
    # class.
    #
    # @api private
    # @return [::Numeric]
    attr_reader :hash

    # Creates an `EOF`-kind token.  This creates the token at the given
    # location.
    #
    # @param location [Location]
    # @return [Token]
    def self.eof(location = Location.default)
      new(:EOF, "", location)
    end

    # Initializes the token with the given kind, value, and location.
    #
    # @param kind [::Symbol] The kind of token.  See {#kind}.
    # @param value [::String] The value of the token.  See {#value}.
    # @param location [Location] The location of the token.  See {#location}.
    def initialize(kind, value, location)
      @kind     = kind
      @value    = value.freeze
      @location = location
      @hash     = [@kind, @value, @location].hash
      freeze
    end

    # Determines if this object is equal to another object.  It first checks
    # for equality using `equal?`, then checks if the other is a token.  If
    # the other object is a token, it checks that the attributes equate.
    #
    # @param other [::Object]
    # @return [Boolean]
    def ==(other)
      equal?(other) || other.is_a?(Token) && @kind == other.kind &&
        @value == other.value && @location == other.location
    end
  end
end
