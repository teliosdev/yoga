require "set"
require "yoga/machine/part"
require "yoga/machine/inclusion"
require "yoga/machine/exclusion"
require "yoga/machine/epsilon"
require "yoga/machine/dot"
require "yoga/machine/prunable"
require "yoga/machine/determinitizable"
require "yoga/machine/optimizable"

module Yoga

  #
  class Machine

    DEFAULT_ALPHABET = (0..255).to_set.freeze
    STUCK_PART = StuckPart.new

    include Prunable
    include Determinitizable
    include Optimizable
    include Dot

    attr_reader :parts

    def initialize
      @parts = Set.new
    end

    def starting
      @parts - @parts.map(&:transitions).map(&:values).flatten
    end

    def accepting
      @parts.select(&:accepting)
    end

    def create_parts(num = 2)
      parts = []

      num.times do
        part = Part.new
        parts  << part
        @parts << part
      end

      parts
    end

    def create_part
      create_parts(1).first
    end

    def merge(other)
      parts.merge(other.parts)
    end

    def self.from(expression)
      case expression
      when Machine
        expression
      when Machine::Part
        machine = new
        machine.tap { |m| m.parts << expressions }
      else
        new
      end
    end

    private

    def alphabet
      @alphabet ||= begin
        transitions = parts.map(&:transitions).
          inject({}, &:merge).keys.
          reject { |x| x.is_a? Epsilon }

        alphabet = Set.new
        transitions.each do |transition|
          if transition.is_a? Exclusion
            alphabet = DEFAULT_ALPHABET
            break
          end

          alphabet.merge(transition)
        end

        alphabet
      end
    end

    def fixed_point(enum)
      added = 1

      until added.zero?
        added  = enum.size
        enum   = yield
        added  = enum.size - added
      end
    end
  end
end
