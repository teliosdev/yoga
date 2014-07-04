module Yoga
  module Helpers
    module BoolAttribute
      module ClassMethods
        def battr_reader(*attributes)
          attributes.each do |attribute|
            class_eval <<-BLOCK
              def #{attribute}?
                @#{attribute}
              end
            BLOCK
          end
        end

        def battr_writer(*attributes)
          attr_writer(*attributes)
        end

        def battr_accessor(*attributes)
          battr_reader(*attributes)
          battr_writer(*attributes)
        end
      end

      def self.included(receiver)
        receiver.extend ClassMethods
      end
    end
  end
end
