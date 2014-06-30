require "yoga/machine/transition"
require "yoga/machine/part"
require "yoga/machine/minimizable"
require "yoga/machine/dotable"
require "yoga/machine/determinitizable"
require "yoga/machine/runable"
require "yoga/machine/no_part_error"

module Yoga
  class Machine

    include Minimizable
    include Dotable
    include Determinitizable
    include Runable
    include Associationable

    def_association :parts, Part

    def initialize
    end

    def initialize_copy(old)
      self.parts = parts.map(&:clone)
      self.parts.each { |_| _.rehash_transitions(self) }
    end

    def starting
      parts.select(&:starting?)
    end

    def accepting
      parts.select(&:accepting?)
    end

    def merge(other)
      parts.merge(other.clone.parts)
    end

    def concat(other)
      other = other.clone
      accepting.each do |accept|
        other.starting.each do |start|
          accept.transitions.create(type: :epsilon, to: start)
          start.starting = false
        end

        accept.accepting = false
      end

      parts.merge(other.parts)
    end

    def alphabet
      #parts.map(&:transitions).map(&:to_a).
      #  map { |_| _.map { |__| __.on.to_a } }.flatten.to_set
      Set.new((0..255).map(&:chr))
    end

  end
end
