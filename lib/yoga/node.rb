# encoding: utf-8
# frozen_string_literal: true

require "mixture"

module Yoga
  # A parser node.  This can be subclassed, or used as is.
  class Node
    include Mixture::Model

    # @!attribute [r] location
    #   The location of the node.  This is normally dependant on the locations
    #   of the tokens that make up this node.
    #
    #   @return [Yoga::Location]
    attribute :location, type: Yoga::Location

    # Initialize the node with the given attributes.  The `:kind` and
    # `:location` attributes are required.
    #
    # @param attributes [Hash] The attributes.
    # @option attributes [::Symbol] :kind The kind of the node.
    # @option attributes [Yoga::Location] :location The location of the node.
    def initialize(attributes)
      self.attributes = attributes
      freeze
    end

    # Creates a new node with the updated attributes.  If any unknown
    # attributes are used, it fails.
    #
    # @param (see #initialize)
    # @option (see #initialize)
    def update(attributes)
      self.class.new(self.attributes.merge(attributes))
    end

    # Prevents all calls to {#update}.  This is used on nodes that should
    # never be updated.  This is a stop-gap measure for incorrectly
    # configured projects.  This, in line with {#update}, creates
    # a duplicate node.
    #
    # @return [Yoga::Node]
    def prevent_update
      node = dup
      node.singleton_class.send(:undef_method, :update)
      node
    end
  end
end
