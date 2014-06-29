require "digest/sha1"
require "securerandom"

module Yoga
  class Machine
    class Part

      attr_accessor :accepting
      attr_accessor :transitions
      attr_accessor :parts
      attr_reader :id

      def initialize
        @accepting = false
        @transitions = {}
        @id = SecureRandom.hex
        @parts = Set.new
      end

      def rehash_transitions(machine)
        transitions = {}
        @transitions.each do |key, value|
          other = machine.parts.find { |_| _ == value }
          transitions[key] = other
        end

        @transitions = transitions
      end

      def accepting!(new_value = !@accepting)
        @accepting = new_value
      end

      def transitions_on(char)
        transitions.select { |e, _| e.match?(char) }.values
      end

      def stuck?
        false
      end

      def ==(other)
        self.class === other &&
        transitions == other.transitions &&
        parts == other.parts &&
        accepting == other.accepting
      end

      def to_s
        "<#{self.class} #{id[0..9]} transitions=#{transitions.keys.inspect} accepting=#{accepting}>"
      end

      alias_method :inspect, :to_s
    end

    class StuckPart < Part
      def initialize
        super
        @id = 'stuck'
      end

      def accepting!
        false
      end

      def stuck?
        true
      end
    end
  end
end
