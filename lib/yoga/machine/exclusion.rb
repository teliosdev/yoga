module Yoga
  class Machine
    class Exclusion < Set

      def match?(character)
        !include?(character)
      end
    end
  end
end
