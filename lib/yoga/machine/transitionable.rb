module Yoga
  class Machine
    module Transitionable

      def hash
        [self.class, super].hash
      end

      def ==(other)
        self.class === other && super
      end

      def to_s
        Transitionable.stringify_alphabet(self)
      end

      def self.escape(_)
        case _
        when "\n"
          "\\\\n"
        when "\r"
          "\\\\r"
        when '"'
          "\\\\\""
        when "'"
          "\\\\'"
        when "\\"
          "\\\\"
        else
          ord = _.ord
          if ord < 0x20 || ord > 0x7e
            "\\\\x#{"%02x" % ord}"
          else
            _
          end
        end
      end

      def self.stringify_alphabet(alphabet)
        if alphabet.size == 1
          groups = alphabet
        else
          groups     = []
          difference = proc { |a, b| b.ord - a.ord }
          chunks     = alphabet.
            sort(&difference).
            each_cons(2).
            chunk(&difference)

          chunks.each do |num, val|
            all_vals = val.flatten.uniq.sort
            if num.abs == 1
              groups << all_vals
            else
              groups.push(*all_vals)
            end
          end
        end

        groups.map do |group|
          if group.size >= 2
            "'#{escape(group.first)}'..'#{escape(group.last)}'"
          else
            "'#{escape(group)}'"
          end
        end.join(", ")
      end

      alias_method :eql?, :==
    end
  end
end
