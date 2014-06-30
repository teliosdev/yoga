require "pathname"
require "erb"

module Yoga
  class Machine
    module Dotable

      def to_dot(out = "machine")
        src = dot_source.open("r")
        context = instance_eval('binding')
        erb = ERB.new(src.read, nil, "-")
        erb.filename = src.path
        content = erb.result(context)

        File.open("#{out}.dot", "w") { |f| f.write(content) }
      end

      def stringify_alphabet(_alphabet = alphabet)
        Dotable.stringify_alphabet(_alphabet)
      end

      def self.stringify_alphabet(alphabet)
        unless alphabet.is_a?(Set)
          alphabet = alphabet.each.to_a.uniq
        end

        if alphabet.size == 1
          groups = [alphabet.to_a]
        else
          groups     = [[]]
          difference = proc { |a, b| b.ord - a.ord }
          chunks     = alphabet.sort_by(&:ord)
          last       = nil

          chunks.each do |char|
            unless last
              groups.last << char
              last = char
              next
            end

            diff = difference[last, char]

            if diff.abs == 1
              groups.last << last << char
            else
              groups << [char]
            end

            last = char
          end
        end

        groups.each(&:uniq!)

        groups.map do |group|
          if group.size >= 2
            "'#{escape(group.first)}'..'#{escape(group.last)}'"
          else
            "'#{escape(group.first)}'"
          end
        end.join(", ")
      end

      def self.escape(_)
        case _
        when "", nil
          ""
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

      private

      def dot_source
        Pathname.new("../template.erb").expand_path(__FILE__)
      end

    end
  end
end
