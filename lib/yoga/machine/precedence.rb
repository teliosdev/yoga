module Yoga
  class Machine

    class Precedence < Struct.new(:name, :level)

      include Comparable

      def <=>(other)
        return other <=> self unless other.is_a? Precedence

        name_comp = name <=> other.name
        return name_comp unless name_comp.zero?

        level <=> other.level
      end

    end

    DEFAULT_PRECEDENCE = Precedence.new("", 0)
  end
end
