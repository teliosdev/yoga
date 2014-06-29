# encoding: utf-8

module Yoga
  class Machine
    class Exclusion < Set

      include Transitionable

      def match?(character)
        !include?(character)
      end

      def to_s
        out = 'Σ'

        if any?
          out << ' - '
          out << super
        end

        out
      end
    end
  end
end
