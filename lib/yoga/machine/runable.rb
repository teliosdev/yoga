module Yoga
  class Machine
    module Runable

      def run_on(text)
        raise unless starting.one?
        current_part = starting.first

        text.split('').each do |char|
          transition = current_part.transitions_for(char)

          p current_part
          raise "No transition" unless transition.any?
          current_part = transition.first.to
        end

        raise "Not an accepting part" unless current_part.accepting?

        true
      end

    end
  end
end
