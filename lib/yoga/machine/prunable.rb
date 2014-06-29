module Yoga
  class Machine
    module Prunable
      def prune
        acceptable_states = Set.new

        starting.each do |start|
          if path = leads_to_accepting?(start)
            acceptable_states.merge(path)
          end
        end

        @parts = acceptable_states.select { |x| leads_to_accepting?(x) }
      end

      def leads_to_accepting?(part)
        return true if part.accepting

        path = Set.new([part])

        fixed_point(path) do
          path.merge(path.each.map(&:transitions).map(&:values).flatten.compact)
        end

        if path.any?(&:accepting)
          path
        else
          false
        end
      end
    end
  end
end
