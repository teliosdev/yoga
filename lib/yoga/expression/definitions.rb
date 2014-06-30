module Yoga
  class Expression
    module Definitions
      module ClassMethods
        def defaults
          {
            "any" => default_any
          }
        end

        def default_any
          machine = Machine.new
          starting, ending = machine.parts.create,
            machine.parts.create

          starting.transitions.
            create(on: Set.new((0..255).map(&:chr)), to: ending)
          starting.starting = true
          ending.accepting  = true

          machine
        end
      end

      def defaults
        self.class.defaults
      end

      def lookup(name)
        @definitions.fetch(name) do
          defaults.fetch(name)
        end.clone

      rescue KeyError
        raise # for now
      end

      def self.included(receiver)
        receiver.extend ClassMethods
      end
    end
  end
end
