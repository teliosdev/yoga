require 'securerandom'

module Yoga
  class Machine
    class Part

      include Comparable
      include Helpers

      attr_accessor :parts
      attr_accessor :id
      battr_accessor :accepting
      battr_accessor :starting

      def_association :transitions, Transition, :sorted
      def_association :parts, Part

      def initialize
        @id          = SecureRandom.hex
        @accepting   = false
        @starting    = false
      end

      def initialize_copy(old)
        self.transitions = transitions.map(&:clone)
      end

      def stuck?
        false
      end

      def transitions_for(character)
        trans = transitions.select { |_| _.match?(character) }

        if trans.size > 1
          $stderr.puts "WARN: transitions for #{character.inspect} exceeded 1 (#{trans.size})"
        end

        trans
      end

      def transition(character)
        transition = transitions_for(character).first

        transition.to if transition
      end

      def contains_parts_from?(machine, options = {})
        machine_parts = case
        when options[:accepting] && options[:starting]
          machine.parts.select { |_| _.accepting? || _.starting? }
        when options[:accepting]
          machine.accepting
        when options[:starting]
          machine.starting
        else
          machine.parts
        end

        parts.any? { |_| machine_parts.include?(_) }
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
          other <=> id
        end
      end

      alias_method :eql?, :==

      def hash
        id.hash
      end

      def to_s
        "#<#{self.class} #transitions=#{transitions.size} " \
          "#parts=#{parts.size} id=#{id[0..9]} " \
          "starting=#{starting?} accepting=#{accepting?}>"
      end

      alias_method :inspect, :to_s
    end

    class StuckPart < Part; def stuck?; true; end; end
  end
end
