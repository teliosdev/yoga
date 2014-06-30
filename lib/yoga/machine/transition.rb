# encoding: utf-8

require "forwardable"

module Yoga
  class Machine
    class Transition < Struct.new(:type, :on, :to)

      include Enumerable
      extend Forwardable

      def_delegator :on, :each

      def initialize(*args)
        if args.size == 1 && args.first.is_a?(Hash)
          hash = args.first
          from_hash(hash)
        else
          super
        end
      end

      def stringify
        out = ""

        if type?(:exclusion)
          out << "Σ"
          out << " - " if any?
        elsif type?(:epsilon)
          out << "ε"
        end

        out << Dotable.stringify_alphabet(self)
      end

      def from_hash(hash)
        self.type = hash["type"] || hash[:type]
        self.on   = hash["on"]   || hash[:on]
        self.to   = hash["to"]   || hash[:to]
      end

      def type?(*checking)
        checking.to_set.include?(type)
      end
    end
  end
end
