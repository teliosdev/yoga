require "yoga/helpers/associationable"
require "yoga/helpers/bool_attribute"

module Yoga
  module Helpers

    def self.included(receiver)
      receiver.send :include, Associationable
      receiver.send :include, BoolAttribute
    end

  end
end
