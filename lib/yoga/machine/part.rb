require 'securerandom'

module Yoga
  class Machine
    class Part

      include Comparable
      include Associationable

      attr_writer :accepting
      attr_writer :starting

      attr_accessor :parts
      attr_accessor :id

      def_association :transitions, Transition
      def_association :parts, Part

      def initialize
        @id          = SecureRandom.hex
        @accepting   = false
        @starting    = false
      end

      def initialize_copy(old)
        self.transitions = transitions.map(&:clone)
      end

      def accepting?
        @accepting
      end

      def starting?
        @starting
      end

      def stuck?
        false
      end

      def transitions_for(character)
        transitions.select { |_| _.match?(character) }
      end

      def transition(character)
        transition = transitions_for(character).first

        transition.to if transition
      end

      def contains_parts_from?(machine)
        parts.any? { |_| machine.parts.include?(_) }
      end

      def rehash_transitions(machine)
        transitions.each do |transition|
          transition.to = machine.parts.
            find { |_| _ == transition.to }
        end
      end

      def <=>(other)
        if other.is_a? Part
          id <=> other.id
        else
          id <=> other
        end
      end

      alias_method :eql?, :==

      def hash
        id.hash
      end

      def to_s
        "#<#{self.class} #transitions=#{transitions.size} #parts=#{parts.size} id=#{id[0..9]} starting=#{starting?} accepting=#{accepting?}>"
        id[0..9]
      end

      alias_method :inspect, :to_s
    end

    class StuckPart < Part; def stuck?; true; end; end
  end
end
