require 'securerandom'

module Yoga
  class Machine
    class Part

      attr_writer :accepting
      attr_writer :starting

      attr_accessor :id

      def initialize
        @id          = SecureRandom.hex
        @accepting   = false
        @starting    = false
      end

      def initialize_copy(old)
        self.transitions = transitions.map(&:clone)
      end

      def rehash_transitions(machine)
        transitions.each do |transition|
          transition.to = machine.parts.
            find { |_| _ == transition.to }
        end
      end

      def transitions
        @_transitions ||= Association.new(self, Transition)
      end

      def transitions=(new_transitions)
        @_transitions = Association.new(self, Transition, new_transitions)
      end

      def accepting?
        @accepting
      end

      def starting?
        @starting
      end

      def ==(other)
        self.class === other && id == other.id
      end

      alias_method :eql?, :==

      def hash
        id.hash
      end
    end
  end
end
