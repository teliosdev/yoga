require "securerandom"

module Yoga
  class Machine
    class Part

      attr_accessor :accepting
      attr_accessor :transitions
      attr_accessor :nfa_parts
      attr_reader :id

      def initialize
        @accepting = false
        @transitions = {}
        @id = SecureRandom.hex
      end

      def accepting!
        @accepting = !@accepting
      end

      def transitions_on(char)
        transitions.select { |e, _| e.match?(char) }.values
      end

      def stuck?
        false
      end

      def to_s
        "<#{self.class} #{@id[0..9]} transitions=#{transitions.keys.inspect} accepting=#{accepting}>"
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
