module Yoga
  class Expression
    module DefaultExpressions
      module ClassMethods
        def defaults
          @_defaults ||= begin
            {
              "any" => default_any
            }
          end
        end

        private

        def default_any
          machine = Machine.new
          start, ending = machine.create_parts
          on = Machine::Inclusion.new((0..255).map(&:chr))
          start.transitions[on] = ending
          ending.accepting!
          machine.parts.map(&:freeze)
          machine
        end
      end

      module InstanceMethods

        def default(name)
          self.class.defaults.fetch(name).clone
        end

        def definition(name)
          @definitions.fetch(name) {
            self.class.defaults.fetch(name)
          }.clone
        end
      end

      def self.included(base)
        base.send :include, InstanceMethods
        base.extend         ClassMethods
      end
    end
  end
end
