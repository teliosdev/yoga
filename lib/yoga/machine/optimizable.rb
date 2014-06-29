require 'pp'

module Yoga
  class Machine
    module Optimizable
      def optimize_transitions
        parts.each do |part|
          transitionables = part.transitions.group_by { |k, v| v }
          transitions = {}

          transitionables.each do |to, ons|
            with = Inclusion.new
            ons.map(&:first).each do |on|
              case on
              when Inclusion
                with.merge(on)
              when Exclusion
                with -= on
              when Epsilon
                with = Epsilon.new
              end
            end

            if !with.is_a?(Epsilon) && with.size > (alphabet.size / 2)
              with = Exclusion.new(alphabet - with)
            end

            transitions[with] = to
          end

          part.transitions = transitions
        end

        self
      end

      def optimize_stuck
        parts.each do |part|
          transitions = part.transitions.reject { |k, v| v == STUCK_PART }
          part.transitions = transitions
        end

        parts.delete(STUCK_PART)
      end
    end
  end
end
