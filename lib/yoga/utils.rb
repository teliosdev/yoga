
module Yoga
  module Utils
    module_function

    # Takes an array of tokens or set/array of tokens and turns it into a
    # single set.
    #
    # @param tokens [<Yoga::Token, ::Set<Yoga::Token>, ::Enumerable>]
    #   The array to flatten into a set.
    # @return [::Set<Yoga::Token>]
    def flatten_into_set(tokens)
      flatten_into_array(tokens).to_set
    end

    # Takes an array of tokens or a set/array of tokens and turns it into a
    # single array.
    #
    # @param tokens [<Yoga::Token>, ::Set<Yoga::Token>, ::Enumerable]
    #   The array to flatten into a set.
    # @return [<Yoga::Token>]
    def flatten_into_array(tokens)
      tokens.flat_map do |part|
        if part.is_a?(::Enumerable)
          flatten_into_array(part)
        else
          part
        end
      end
    end
  end
end
