module Yoga
  class Machine
    module Determinitizable
      # Makes the machine deterministic.
      def determinitize
        return self if deterministic?
        machine = Machine.new
        prune
        raise unless starting.size == 1
        determinize_parts(machine, starting[0])
        machine.parts << STUCK_PART
        machine.optimize_transitions
        machine.optimize_stuck
        machine
      end

      def determinize_parts(machine, parts)
        parts = closure([parts].flatten.to_set)

        if determinital = machine.parts.
          find { |p| p.nfa_parts == parts }
          return determinital
        end

        new_part = machine.create_part
        new_part.nfa_parts = parts
        new_part.accepting! if parts.any?(&:accepting)

        alphabet.each do |char|
          moves = move(new_part.nfa_parts, char)
          if moves.empty?
            transition = STUCK_PART
          else
            transition = determinize_parts(machine, moves)
          end
          new_part.transitions[Inclusion.new([char])] = transition
        end


        new_part
      end

      def move(parts, character)
        parts = parts.dup
        moves = Set.new

        parts.each do |part|
          moves.merge(part.transitions_on(character))
        end

        moves.to_a
      end

      def closure(parts)
        epsilons = Set.new(parts)
        fixed_point(epsilons) do
          epsilons.map(&:transitions).each do |transitions|
            epsilons.merge(transitions.
                           select { |e, _| e.is_a? Epsilon }.values)
          end

          epsilons
        end
        epsilons
      end

      private

      def deterministic?
        parts.all? do |part|
         !part.transitions.any? {|k, _| k.is_a? Epsilon }
        end
      end
    end
  end
end
