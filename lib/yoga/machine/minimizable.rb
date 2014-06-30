module Yoga
  class Machine
    module Minimizable

      def minimize!
        minimize_starting
        minimize_epsilon_transitions
        minimize_parts
        minimize_transitions

        self
      end

      def minimize
        clone.minimize!
      end

      # Make sure that there is only one starting state and one
      # accepting state.
      def minimize_starting
        raise NoPartError,
          "Machine contains no starting parts" unless starting.any?
        raise NoPartError,
          "Machine contains no accepting parts" unless accepting.any?

        if starting.size > 1
          new_starting = parts.create

          starting.each do |start|
            new_starting.transitions.create(type: :epsilon, to: start)
            start.starting = false
          end

          new_starting.starting = true
        end

        if accepting.size > 1
          new_ending = parts.create

          accepting.each do |accept|
            accept.transitions.create(type: :epsilon, to: new_ending)
            accept.accepting = false
          end

          new_ending.accepting = true
        end

        self
      end

      # Remove states that have one epsilon transition.
      def minimize_epsilon_transitions
        parts.reject! do |part|
          if part.transitions.size == 1 &&
              part.transitions.first.type?(:epsilon)

            to_state = part.transitions.first.to
            to_state.accepting = to_state.accepting? ||
              part.accepting?
            to_state.starting  = to_state.starting?  ||
              part.starting?

            containing = parts.select { |p| p.transitions.
              any? { |_| _.to == part } }

            containing.each do |contain|
              contain.transitions.each do |transition|
                if transition.to == part
                  transition.to = to_state
                end
              end
            end

            true
          else
            false
          end
        end
      end

      # Removes parts that are not on a path from a starting state
      # to an accepting state.
      def minimize_parts
        acceptable = Set.new

        starting.each do |start|
          path = leads_to_accepting?(start)

          acceptable.merge(path) if path
        end

        @parts = acceptable.select { |_| leads_to_accepting?(_) }
      end

      # Combines transitions that lead to the same state.
      def minimize_transitions(allow_exclusion = false)
        parts.each do |part|
          transitionables = part.transitions.group_by { |t| t.to }
          transitions = Set.new

          transitionables.each do |to, trans|
            with = Transition.new(:inclusion)

            trans.each do |transition|
              case transition.type
              when :inclusion
                with.on.merge(transition.on)
              when :exclusion
                with.on -= transition.on
              when :epsilon
                with.type = :epsilon
              end
            end

            if allow_exclusion && !with.type?(:epsilon) &&
                with.on.size > (alphabet.size / 2)
              with.type = :exclusion
              with.on = alphabet - with.on
            end

            with.to = to
            transitions << with
          end

          part.transitions = transitions
        end
      end

      def leads_to_accepting?(part)
        touches = Set.new([part])

        fixed_point(touches) do
          touches.merge(touches.map(&:transitions).flatten.map(&:to))
        end

        if touches.any?(&:accepting?)
          touches
        elsif part.accepting?
          []
        else
          false
        end
      end

      def fixed_point(enum)
        added = 1

        until added.zero?
          added = enum.size
          yield
          added = enum.size - added
        end
      end
    end
  end
end
