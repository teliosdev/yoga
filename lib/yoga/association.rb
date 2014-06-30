require "forwardable"
require "set"
require "yoga/association/associationable"

module Yoga
  class Association < Set

    extend Forwardable

    def_delegator :to_a, :last
    def_delegator :to_a, :first
    def_delegator :to_a, :[]

    def initialize(parent, child, *args, &to_add)
      @_parent = parent
      @_child  = child
      @_to_add = to_add || proc {}
      super(*args)
    end

    def create(*args, &block)
      child = build(*args, &block)
      self << child
      child
    end

    def build(*args, &block)
      child = @_child.new(*args, &block)
      @_to_add.call(child)
      child
    end

  end
end
