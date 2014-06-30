module Yoga
  class Expression
    module Compiler

      def compile_modifier(mod, group)
        case mod
        when :STAR
          compile_star(group)
        when :PLUS
          compile_plus(group)
        when :OPTIONAL
          compile_optional(group)
        end
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

      def compile_paren(expression)

      end

      def compile_string(string)
        machine = Machine.new

        parts = string[1].size.succ.times.
          map { |i| machine.parts.create }

        string[1].split('').each_with_index do |char, i|
          parts[i].transitions.create(on: [char].to_set,
                                      to: parts[i.succ],
                                      type: :inclusion)
        end

        parts.first.starting = true
        parts.last.accepting = true

        machine.to_dot('test')

        machine
      end

      def compile_contain(contain)

      end

      def compile_number(number)

      end

      def compile_identifier(ident)

      end

      def compile_star(group)

      end

      def compile_plus(group)

      end

      def compile_optional(group)

      end

      def compile_union(left, right)

      end

      def compile_intersect(left, right)

      end

      def compile_sdifference(left, right)

      end

      def compile_difference(left, right)

      end
    end
  end
end
