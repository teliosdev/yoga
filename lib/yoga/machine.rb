require "yoga/machine/transition"
require "yoga/machine/part"
require "yoga/machine/minimizable"
require "yoga/machine/dotable"
require "yoga/machine/no_part_error"

module Yoga
  class Machine

    include Minimizable
    include Dotable

    def initialize
    end

    def parts
      @_parts ||= Association.new(self, Part)
    end

    def parts=(new_parts)
      @_parts = Association.new(self, Part, new_parts)
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

    def alphabet
      parts.map(&:transitions).map(&:to_a).
        map { |_| _.map { |__| __.on.to_a } }.flatten.to_set
    end

  end
end
