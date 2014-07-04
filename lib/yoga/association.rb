require "forwardable"
require "set"

module Yoga
  class Association

    extend Forwardable
    include Comparable

    def_delegator :to_a, :last
    def_delegator :to_a, :first
    def_delegator :to_a, :[]
    def_delegator :@content, :<=>
    def_delegator :@content, :eql?

    def initialize(parent, child, source = [],
      type = :unsorted, &to_add)
      @parent = parent
      @child  = child
      @to_add = to_add || proc {}
      @content = if type == :sorted
        SortedSet.new(source)
      else
        Set.new(source)
      end
    end

    def create(*args, &block)
      child = build(*args, &block)
      self << child
      child
    end

    def build(*args, &block)
      child = @child.new(*args, &block)
      @to_add.call(child)
      child
    end

    def is_a?(klass)
      super || @content.is_a?(klass)
    end

    def inspect
      @content.inspect
    end

    def to_s
      @content.to_s
    end

    def to_a
      @content.to_a
    end

    def method_missing(method, *args, &block)
      if @content.respond_to?(method)
        @content.public_send(method, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(*_)
      @content.respond_to?(*_)
    end

  end
end
