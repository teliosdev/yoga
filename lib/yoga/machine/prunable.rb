module Yoga
  class Machine
    module Prunable

      def prune
        fixed_point(parts) do
          prune_transitions
          prune_paths
          parts
        end

        self
      end

      def prune_starting(start_parts = nil)
        if start_parts == nil
          start_parts = starting
          return self if start_parts.size == 1
        end

        start = create_part
        start_parts.each do |part|
          start.transitions[Epsilon.new] = part
        end

        self
      end

      def prune_transitions
        parts.each do |part|
          transitions = part.transitions.
            select { |k, v| parts.any? { |p| p == v } }
          part.transitions = transitions
        end

        self
      end

      def prune_paths
        acceptable_parts = Set.new

        starting.each do |start|
          if path = leads_to_accepting?(start)
            acceptable_parts.merge(path)
          end
        end

        @parts = acceptable_parts.select { |x| leads_to_accepting?(x) }
        self
      end

      private

      def leads_to_accepting?(part)
        path = Set.new([part])

        fixed_point(path) do
          path.merge(path.each.map(&:transitions).map(&:values).flatten.compact)
        end

        if path.any?(&:accepting)
          path
        elsif part.accepting
          []
        else
          false
        end
      end
    end
  end
end
