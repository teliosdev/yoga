module Yoga
  class Machine
    class Inclusion < Set

      def match?(character)
        include?(character)
      end

      def hash
        [self.class, super].hash
      end

      def ==(other)
        self.class === other and super
      end

      alias_method :eql?, :==

      private

      def to_comparable
        [self.class, self]
      end
    end
  end
end
