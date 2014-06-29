# encoding: utf-8

module Yoga
  class Machine
    class Epsilon

      include Enumerable

      def initialize
        @content = ['ε'].freeze
      end

      def match?(char)
        false
      end

      def each(*a, &b)
        @content.each(*a, &b)
      end
    end
  end
end
