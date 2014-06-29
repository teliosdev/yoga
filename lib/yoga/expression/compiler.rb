require "set"

module Yoga
  class Expression
    module Compiler

      def compile_contain(contain)
        machine = Machine.new
        first, second = machine.create_parts(2)
        first.transitions[setify(contain[1])] = second
        second.accepting!
        machine
      end

      def compile_string(string)
        machine = Machine.new
        parts = machine.create_parts(string[1].size + 1)

        string[1].split('').each_with_index do |char, i|
          parts[i].transitions[setify(char)] = parts[i + 1]
        end

        parts.last.accepting!
        machine
      end

      def compile_number(number)
        machine = Machine.new
        first, second = machine.create_parts
        first.transitions[Machine::Inclusion.new([number])] = second
        second.accepting!
        machine
      end

      def compile_binop(op, left, right)
        case op
        when :UNION
          compile_union(left, right)
        when :INTERSECT
        when :SDIFFERENCE
        when :DIFFERENCE
        end
      end

      def compile_union(left, right)
        machine = Machine.new
        machine.merge(left)
        machine.merge(right)

        start, ending = machine.create_parts

        (left.starting + right.starting).each do |part|
          start.transitions[Machine::Epsilon.new] = part
        end

        (left.accepting + right.accepting).each do |part|
          part.transitions[Machine::Epsilon.new] = ending
          part.accepting!
        end

        ending.accepting!

        machine
      end

      private

      def setify(string)
        Machine::Inclusion.new(string.split(''))
      end
    end
  end
end
