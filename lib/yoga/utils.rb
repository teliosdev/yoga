# encoding: utf-8
# frozen_string_literal: true

module Yoga
  # Utilities used with the Yoga module.
  #
  # @api private
  module Utils
  module_function

    # Takes an array of tokens or set/array of tokens and turns it into a
    # single set.
    #
    # @param tokens [<Yoga::Token, ::Set<Yoga::Token>, ::Enumerable>]
    #   The array to flatten into a set.
    # @return [::Set<Yoga::Token>]
    def flatten_into_set(tokens)
      case tokens
      when ::Set then tokens
      when ::Array then ::Set.new(tokens)
      else
        ::Set.new(tokens.to_a)
      end
    end
  end
end
