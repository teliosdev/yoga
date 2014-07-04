# encoding: utf-8

require "forwardable"

module Yoga
  class Machine
    class Transition < Struct.new(:type, :on, :to, :prec)

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

        self.type ||= :inclusion
        self.on   ||= Set.new
        self.prec ||= DEFAULT_PRECEDENCE
      end

      def initialize_copy(old)
        super
        self.on   = old.on.clone
        self.prec = old.prec.clone
      end

      def <=>(other)
        return other <=> self unless other.is_a? Transition

        [:type, :to, :prec].each do |prop|
          comp = self[prop] <=> other[prop]
          return comp unless !comp || comp.zero?
        end

        0
      end

      def match?(character)
        case type
        when :inclusion
          on.include?(character)
        when :exclusion
          !on.include?(character)
        when :epsilon
          false
        end
      end

      def stringify
        out = ""

        case type
        when :exclusion
          out << "Σ"
          out << " - " if any?
        when :epsilon
          out << "ε"
        end

        if !epsilon? && !none?
          out << Dotable.stringify_alphabet(self)
        end

          out << " / #{prec.name}(#{prec.level})"

        out
      end

      def from_hash(hash)
        self.type = hash["type"] || hash[:type]
        self.on   = hash["on"]   || hash[:on]
        self.to   = hash["to"]   || hash[:to]
      end

      def type?(*checking)
        checking.to_set.include?(type)
      end

      def epsilon?
        type == :epsilon
      end

      def inclusion?
        type == :inclusion
      end

      def exclusion?
        type == :exclusion
      end
    end
  end
end
