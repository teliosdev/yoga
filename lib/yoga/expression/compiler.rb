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

      def compile_transitional(data, expression)
        trans, state_type, name, level = data
        name = name.map(&:last).join
        parts = case state_type
        when :DOLLAR # these are accepting states
          expression.accepting
        when :PERCENT # starting states
          expression.starting
        when :AT # any states
          expression.parts
        end

        parts.each do |part|
          case trans
          when :LESSER # <, transitions out of
            part.transitions.each do |tran|
              tran.prec.name = name
              tran.prec.level = level.to_i
            end
          when :GREATER # >, transitions into
            trans_to = expression.parts.
              map(&:transitions).map(&:to_a).flatten.
              select { |_| _.to == part }

            trans_to.each do |tran|
              tran.prec.name = name
              tran.prec.level = level.to_i
            end
          end
        end

        expression
      end

      def compile_paren(expression)
        machine = Machine.new

        raise ArgumentError,
          "Expected an array of machine, got " \
          "#{expression.class}" \
          "<#{expression.find { |_| _.class != Machine }.class}>" \
          unless expression.respond_to?(:all?) &&
            expression.all? { |_| _.class == Machine }

        case expression.size
        when 0
          return machine
        when 1
          return expression[0].clone
        end

        expression.each do |exp|
          machine.concat(exp)
        end

        machine
      end

      # Returns a minimal machine.
      def compile_string(string)
        machine = Machine.new

        parts = string[1].size.succ.times.
          map { |i| machine.parts.create }

        string[1].split('').each_with_index do |char, i|
          parts[i].transitions.
            create(on: [char].to_set, to: parts[i.succ])
        end

        parts.first.starting = true
        parts.last.accepting = true

        machine
      end

      # Returns a minimal machine.
      def compile_contain(contain)
        machine = Machine.new
        starting = machine.parts.create
        ending   = machine.parts.create

        transition = starting.transitions.create(to: ending)

        contain.each do |part|
          case part[0]
          when :INVERT
            transition.type = :exclusion
          when :SET
            transition.on.merge(part[1]..part[2])
          when :CHARACTER
            transition.on << part[1]
          else
            raise ArgumentError, "Unkown token #{part[0]}"
          end
        end

        starting.starting = ending.accepting = true
        machine
      end

      # Returns a minimal machine.
      def compile_number(number)
        machine = Machine.new
        starting = machine.parts.create
        ending   = machine.parts.create

        transition = starting.transitions.create(to: ending)

        transition.on << number.chr

        starting.starting = ending.accepting = true
        machine
      end

      def compile_identifier(ident)
        lookup(ident.map(&:last).join)
      end

      def compile_star(machine)
        ensure_minimal(machine) do |starting, accepting|
          accepting.transitions.create(type: :epsilon, to: starting)
          starting.transitions.create(type: :epsilon, to: accepting)
        end
      end

      def compile_plus(machine)
        ensure_minimal(machine) do |starting, accepting|
          accepting.transitions.create(type: :epsilon, to: starting)
        end
      end

      def compile_optional(machine)
        ensure_minimal(machine) do |starting, accepting|
          starting.transitions.create(type: :epsilon, to: accepting)
        end
      end

      def compile_union(left, right)
        machine = Machine.new
        machine.merge(left)
        machine.merge(right)

        machine
      end

      def compile_intersect(left, right)
        union = compile_union(left, right)

        union.determinitize!

        union.accepting.each do |accept|
          unless accept.contains_parts_from?(left) &&
            accept.contains_parts_from?(right)
            accept.accepting = false
          end
        end

        union#.minimize!
      end

      def compile_difference(left, right)
        union = compile_union(left, right)
        union.determinitize!

        union.minimize_transitions
      end

      def compile_sdifference(left, right)
        paren = compile_paren([
          compile_star(lookup("any")),
          right,
          compile_star(lookup("any"))
        ])

        compile_difference(left, paren)
      end

      private

      def ensure_minimal(machine)
        machine.minimize_starting unless machine.minimal?

        starting, accepting = machine.starting.first,
          machine.accepting.first

        yield starting, accepting

        machine
      end
    end
  end
end
