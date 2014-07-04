require "thread"

module Yoga
  class Machine

    STUCK_PART = StuckPart.new

    # Makes the machine deterministic by performing the subset
    # construction algorithm.
    module Determinitizable

      NUMBER_OF_THREADS = 5

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
        first = starting.first
        @old_parts, self.parts = self.parts, []
        start = self.parts.create
        start.parts = closure([first])
        start.accepting = start.parts.any?(&:accepting?)
        start.starting = true

        workload = [start]

        until workload.empty? do
          part = workload.pop

          alphabet.each do |char|
            moves = move(part.parts, char)

            if moves.any?
              moves = closure(moves)

              transitional = self.parts.
                find { |_| _.parts == moves } || begin
                new_part = self.parts.create
                new_part.parts = moves
                new_part.accepting = new_part.parts.any?(&:accepting?)
                workload << new_part
                new_part
              end

              part.transitions.
                create(on: Set.new([char]), to: transitional)
            end
          end
        end

        @deterministic = true

        minimize_transitions
        minimize_nondistinct
        minimize!
        minimize_transitions

        self
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

        moves
      end
    end
  end
end
