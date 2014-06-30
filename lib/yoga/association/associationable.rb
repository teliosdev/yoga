module Yoga
  module Associationable
    module ClassMethods

      def def_association(name, klass)
        class_eval <<-BLOCK
          def #{name}
            @_#{name} ||= ::Yoga::Association.new(self, #{klass})
          end

          def #{name}=(new_val)
            @_#{name} = ::Yoga::Association.new(self, #{klass}, new_val)
          end
        BLOCK
      end

    end

    def self.included(receiver)
      receiver.extend ClassMethods
    end
  end
end
