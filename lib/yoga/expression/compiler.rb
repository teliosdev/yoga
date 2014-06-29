require "set"

module Yoga
  class Expression
    module Compiler

      def compile_contain(contain)
        values = Machine::Inclusion.new

        contain.each do |part|
          if part[0] == :SET
            values.merge(part[1]..part[2])
          elsif part[0] == :CHARACTER
            values << part[1]
          end
        end

        machine = Machine.new
        first, second = machine.create_parts(2)
        first.transitions[values] = second
        second.accepting!(true)
        machine
      end

      def compile_string(string)
        machine = Machine.new
        parts = machine.create_parts(string[1].size + 1)

        string[1].split('').each_with_index do |char, i|
          parts[i].transitions[setify(char)] = parts[i + 1]
        end

        parts.last.accepting!(true)
        machine
      end

      def compile_identifier(ident)
        ident = ident.map(&:last).join
        definition(ident)
      end

      def compile_paren(body)
        machine = Machine.new

        return body[0] if body.size == 1
        return machine if body.size.zero?

        raise unless body.all? { |_| _.class == Machine }

        body = body.dup
        machine = body.shift
        body.each do |additional|
          machine = concat(machine, additional)
        end

        machine.prune_starting

        machine
      end

      def compile_modifier(modifier, value)
        case modifier
        when :STAR
          compile_star(value)
        when :PLUS
          compile_plus(value)
        when :OPTIONAL
          compile_optional(value)
        end
      end

      def compile_star(value)
        starting, ending = value.create_parts

        value.starting.each do |start|
          starting.transitions[Machine::Epsilon.new] = start
        end

        value.accepting.each do |accept|
          accept.transitions[Machine::Epsilon.new] = starting
        end

        starting.transitions[Machine::Epsilon.new] = ending
        ending.accepting!

        value.prune_starting([starting])
      end

      def compile_plus(value)
        concat(value.clone, compile_star(value.clone))
      end

      def compile_optional(value)
        accepting = if value.accepting.size == 1
          value.accepting.first
        else
          Machine::Part.new.tap { |_| _.accepting! }
        end

        value.starting.each do |start|
          start.transitions[Machine::Epsilon.new] = accepting
        end

        value
      end

      def compile_number(number)
        machine = Machine.new
        first, second = machine.create_parts
        first.transitions[Machine::Inclusion.new([number.chr])] = second
        second.accepting!(true)
        machine
      end

      def compile_binop(op, left, right)
        case op
        when :UNION
          compile_union(left, right)
        when :INTERSECT
          compile_intersect(left, right)
        when :SDIFFERENCE
          compile_sdifference(left, right)
        when :DIFFERENCE
          compile_difference(left, right)
        end
      end

      def compile_union(left, right)
        unify(left, right)
      end

      def compile_intersect(left, right)
        left_accepting  = left.accepting
        right_accepting = right.accepting

        unify(left, right) do |part|
          if part.accepting
            accept = left_accepting.intersect?(part.parts) &&
              right_accepting.intersect?(part.parts)

            part.accepting! unless accept
          end
        end.prune
      end

      def compile_difference(left, right)
        left_accepting = left.accepting
        right_accepting = right.accepting

        unify(left, right) do |part|
          accept = !right_accepting.intersect?(part.parts)

          part.accepting! unless accept
        end
      end

      def compile_sdifference(left, right)
        paren = compile_paren([
          compile_star(default("any")),
          right,
          compile_star(default("any"))
        ])
        paren.dot('paren')
        out = compile_difference(left, paren)
        out
      end

      private

      def setify(string)
        Machine::Inclusion.new(string.split(''))
      end

      def unify(left, right)
        machine = Machine.new
        machine.merge(left)
        machine.merge(right)

        machine.prune_starting
        machine.determinitize
        machine.parts.each(&Proc.new) if block_given?

        ending = machine.create_part
        machine.accepting.each do |part|
          part.transitions[Machine::Epsilon.new] = ending
          part.accepting!(false)
        end

        ending.accepting!(true)
        machine.determinitize
      end

      def concat(left, right)
        machine = Machine.new
        machine.merge(left)
        machine.merge(right)

        left.accepting.each do |accept|
          right.starting.each do |start|
            accept.transitions[Machine::Epsilon.new] = start
          end

          accept.accepting! false
        end

        machine
      end
    end
  end
end
