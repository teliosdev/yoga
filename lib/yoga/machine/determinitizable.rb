module Yoga
  class Machine

    STUCK_PART = StuckPart.new

    # Makes the machine deterministic by performing the subset
    # construction algorithm.
    module Determinitizable


      def determinitize
        clone.determinitize!
      end

      def deterministic?
        @deterministic
      end

      def deterministic=(new_value)
        @deterministic = new_value
      end

      def determinitize!
        return self if deterministic?

        minimize_starting unless minimal?
        starting = self.starting.first
        @old_parts, self.parts = self.parts, []
        part = determinitize_part(starting)
        @deterministic = true
        part.starting = true

        self
      end

      def determinitize_part(parts)
        parts = closure([parts].flatten.to_set)

        if determinital = self.parts.find { |_| _.parts == parts }
          return determinital
        end

        part = self.parts.create
        part.parts = parts
        part.accepting = true if parts.any?(&:accepting?)

        alphabet.each do |char|
          moves = move(part.parts, char)

          unless moves.empty?
            transition = determinitize_part(moves)
            part.transitions.create(on: [char].to_set, to: transition)
          end
        end

        part
      end

      def closure(parts)
        epsilons = Set.new(parts)

        fixed_point(epsilons) do
          epsilons.map(&:transitions).each do |transitions|
            v = transitions.select(&:epsilon?).map(&:to)
            epsilons.merge(v.compact)
          end
        end

        epsilons
      end

      def move(parts, character)
        moves = Set.new

        parts.each do |part|
          moves.merge part.transitions_for(character).map(&:to)
        end

        moves.to_a
      end
    end
  end
end
