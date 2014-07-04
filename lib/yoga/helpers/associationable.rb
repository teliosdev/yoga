module Yoga
  module Helpers
    module Associationable
      module ClassMethods

        def def_association(name, klass, option = :unsorted)
          class_eval <<-BLOCK
            def #{name}
              @_#{name} ||= ::Yoga::Association.new(self, #{klass}, [], #{option.inspect})
            end

            def #{name}=(new_val)
              @_#{name} = ::Yoga::Association.new(self, #{klass}, new_val, #{option.inspect})
            end
          BLOCK
        end

      end

      def self.included(receiver)
        receiver.extend ClassMethods
      end
    end
  end
end
