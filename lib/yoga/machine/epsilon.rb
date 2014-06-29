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

      def to_s
        "ε"
      end

      def inspect
        "#<#{self.class}>"
      end
    end
  end
end
