module Yoga
  class Machine
    module Minimizable

      def minimal?
        starting.size == 1 && accepting.size == 1
      end

      def minimize!
        @minimizing = true
        minimize_epsilon_transitions!
        minimize_starting!
        minimize_parts!
        minimize_transitions! true
        @minimizing = false

        self
      end

      def minimize
        clone.minimize!
      end

      # Make sure that there is only one starting state and one
      # accepting state.
      def minimize_starting!
        raise NoPartError,
          "Machine contains no starting parts" unless starting.any?
        raise NoPartError,
          "Machine contains no accepting parts" unless accepting.any?

        return self if deterministic?

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

      # Remove excess epsilon transitions.
      def minimize_epsilon_transitions!
        parts.each do |part|
          fixed_point(part.transitions) do
            part.transitions.select(&:epsilon?).each do |transition|
              to_state = transition.to
              if to_state.transitions.all?(&:epsilon?)
                part.transitions.merge(to_state.transitions)
                part.transitions.delete(transition)
                part.accepting = part.accepting? || to_state.accepting?
                part.starting = part.starting? || to_state.starting?
              elsif to_state == part
                part.transitions.delete(transition)
              end
            end

            if part.transitions.size == 1 && part.transitions.first.epsilon?
              to_merge = part.transitions.first
              part.transitions.merge(to_merge.to.transitions)
              part.transitions.delete(to_merge)
            end
          end
        end

        self
      end

      # Removes parts that are not on a path from a starting state
      # to an accepting state.
      def minimize_parts!
        acceptable = Set.new

        starting.each do |start|
          path = leads_to_accepting?(start)

          acceptable.merge(path) if path
        end

        self.parts = acceptable.select { |_| leads_to_accepting?(_) }

        self
      end

      # Combines transitions that lead to the same state.
      def minimize_transitions!(allow_exclusion = false)
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
                with.on.merge(alphabet - transition.on)
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

        self
      end

      def minimize_hopcroft

      end

      private

      def leads_to_accepting?(part)
        touches = Set.new([part])

        fixed_point(touches) do
          touches.merge(touches.map(&:transitions).
                        map { |_| _.map(&:to) }.flatten)
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
