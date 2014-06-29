module Yoga
  class Machine
    class Inclusion < Set

      include Transitionable

      def match?(character)
        include?(character)
      end

      alias_method :eql?, :==
    end
  end
end
