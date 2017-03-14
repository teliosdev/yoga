# encoding: utf-8
# frozen_string_literal: true

module Yoga
  module Parser
    # helpers that manage the state of the parser.  This can be things like
    # peeking, shifting, and erroring.
    module Helpers
      # The class methods for helpers for the parser.  These are defined
      # on the class of the parser.
      module ClassMethods
        # The default value for a switch.  This matches no tokens and
        # performs no actions.  This cannot be modified.
        #
        # @return [{::Symbol => ::Proc}]
        DEFAULT_SWITCH = {}.freeze

        # Predefines a switch logic.  This is used to do set checking for the
        # keys instead of array checking.  This reduces the time it takes for
        # a switch statement to be performed.
        #
        # @param name [::Symbol] The name of the switch.  This is used in the
        #   method to look up the switch.
        # @param mapping [{::Symbol, <::Symbol> => ::Proc}, nil] A
        #   mapping of symbol(s) to callables.  If no value is given, then it
        #   returns the current switch for the given name.
        # @return [{::Symbol => {::Symbol => ::Proc}}]
        #
        # @overload switch(name)
        #   Retrieves the switch map for the given name.  This is basically
        #   a lookup table for the peek token.  The keys represent the peek
        #   token kind, and the values are the actions that should be taken
        #   for the given token kind.
        #
        #   @param name [::Symbol] The name of the switch map.  This is
        #     typically the same as the first set name and the node name for
        #     the rule.
        #   @return [{::Symbol => ::Proc}] The switch map.
        # @overload switch(name, mapping)
        #   Sets the switch map for the given name.  This does some internal
        #   mapping before finalizing the mapping.  First, it converts all
        #   values into a proc; then, it expands all array (or enumerable)
        #   keys into seperate entries.  It then sets the first set using the
        #   name of the switch as the name of the first set, and the keys of
        #   the switch map as the first set.
        #
        # @example
        #   Parser.switch(:Definition,
        #     :":" => proc { parse_directive },
        #     :enum => proc { parse_enum },
        #     :def => proc { parse_function },
        #     :class => proc { parse_class },
        #     :struct => proc { parse_struct })
        #
        #   @param name [::Symbol] The name of the switch map.  A first set
        #     with the same name is created as well.
        #   @param mapping [{::Symbol, ::Enumerable<::Symbol> =>
        #     ::Proc, ::Symbol}] The mapping.
        #   @return [void]
        def switch(name, mapping = nil)
          @_switches ||= {}
          name = name.intern
          return @_switches[name] || DEFAULT_SWITCH unless mapping
          switch = {}
          mapping.each do |k, v|
            v = v.is_a?(::Proc) ? v : proc { |*a| send(v, *a) }
            Array(k).each { |n| switch[n] = v }
          end

          first(name, switch.keys)
          @_switches[name] = switch
        end

        # The first sets.  The key is the name of a node, and the value
        # is a set of all tokens that can be at the start of that node.
        #
        # @return [{::Symbol => ::Set<::Symbol>}]
        def firsts
          @firsts ||= Hash.new { |h, k| h[k] = Set.new }
        end

        # @overload first(name)
        #   Retrieves the first set for the given node name.  If none exists,
        #   a `KeyError` is raised.
        #
        #   @api private
        #   @param name [::Symbol] The name of the node to look up the first
        #     set for.
        #   @return [::Set<::Symbol>] The first set
        #   @raise [::KeyError] If the node has no defined first set.
        # @overload first(name, tokens)
        #   Merges the given tokens into the first set of the name of the
        #   node given.
        #
        #   @api private
        #   @param name [::Symbol] The name of the node that the first set is
        #     for.
        #   @param tokens [<::Symbol>] The tokens that act as the first set
        #     for the node.
        #   @return [void]
        def first(name, tokens = nil)
          if tokens
            firsts[name] = Set.new(Array(tokens))
          else
            firsts.fetch(name)
          end
        end
      end

      # Peeks to the next token.  If peeking would cause a `StopIteration`
      # error, it instead returns the last value that was peeked.
      #
      # @return [Yoga::Token]
      def peek
        @_last = (@buffer.any? ? @buffer.first : @tokens.peek)
      rescue ::StopIteration
        @_last
      end

      # Peeks out to a given token.  If peeking would cause a `StopIteration`
      # error, it instead returns the last value that was peeked.  This is
      # an expensive operation, and should be used sparingly.  All other
      # methods work as normal, even after this.
      #
      # @param to [::Numeric] The distance to peek to.
      # @return [Yoga::Token]
      def peek_out(to)
        return @buffer[to] if to <= @buffer.size
        (to - @buffer.size + 1).times { @buffer << @tokens.next }
        @buffer.last
      rescue ::StopIteration
        @buffer.last
      end

      # Pushes back tokens onto the buffer.  These, in reverse order, are
      # the tokens that are pulled out by `peek/1`, `peek_to/1`, `expect/1`,
      # and `shift/1`.
      #
      # @param tokens [<Yoga::Token>]
      # @return [self]
      def push(*tokens)
        tokens.each { |t| @buffer.push(t) }
        self
      end

      alias_method :<<, :push

      # Switches the function executed based on the given nodes.  If the
      # peeked node matches one of the mappings, it calls the resulting
      # block or method.
      #
      # If the peeked token is not in the map, then {#error} is called.
      #
      # @see ClassMethods#switch
      # @param name [::Symbol] The name of the switch to use.
      # @return [::Object] The result of calling the block.
      def switch(name, *param, token: peek)
        switch = self.class.switch(name)
        block = switch
                .fetch(token.kind) { switch.fetch(:$else) { error(switch.keys) } }
        instance_exec(*param, &block)
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity

      # "Collects" a set of nodes until a terminating token.  It yields
      # until the peek is the token.
      #
      # @param ending [::Symbol] The terminating token.
      # @param join [::Symbol, nil] The token that joins each of the
      #   children.  This is the comma between arguments.
      # @return [::Array] The collected nodes from the yielding process.
      def collect(ending, join = nil)
        children = []
        join = Utils.flatten_into_set(join) if join
        ending = Utils.flatten_into_set(ending) if ending

        return [] if (ending && peek?(ending)) || (!ending && !join)

        children << yield

        cond = proc do
          (join ? peek?(join) && expect(join) : true) &&
            !(ending && peek?(ending))
        end

        (children << yield) while cond.call
        children
      end

      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity

      # Checks to see if any of the given kinds includes the next token.
      #
      # @param tokens [<::Symbol>] The possible kinds.
      # @return [::Boolean]
      def peek?(tokens)
        Utils.flatten_into_set(tokens).include?(peek.kind)
      end

      # Peeks out to a specific point in the future to match.  This is an
      # expensive operation.
      #
      # @see #peek?
      # @see peek_out
      # @param to [::Numeric] The distance to peek to.
      # @param tokens [<::Symbol>] The kinds of tokens to check for.
      # @return [::Boolean]
      def peek_out?(to, tokens)
        Utils.flatten_into_set(tokens).include?(peek_out(to).kind)
      end

      # Shifts to the next token, and returns the old token.
      #
      # @return [Yoga::Token]
      def shift
        @buffer.any? ? @buffer.shift : @tokens.next
      rescue ::StopIteration
        fail InvalidShiftError, location: peek.location
      end

      # Sets up an expectation for a given token.  If the next token is
      # an expected token, it shifts, returning the token; otherwise,
      # it {#error}s with the token information.
      #
      # @param tokens [<::Symbol>] The expected tokens.
      # @return [Yoga::Token]
      def expect(tokens)
        tokens = Utils.flatten_into_set(tokens)
        return shift if peek?(tokens)
        error(tokens)
      end

      # Retrieves the first set for the given node name.
      #
      # @param name [::Symbol]
      # @return [::Set<::Symbol>]
      def first(name)
        self.class.first(name)
      end

      # Errors, noting the expected tokens, the given token, the location
      # of given tokens.  It does this by failing.
      #
      # @param tokens [<::Symbol>] The expected tokens.
      # @return [void]
      def error(tokens)
        fail Yoga::UnexpectedTokenError, expected: tokens, got: peek.kind,
          location: peek.location
      end

      # Internal ruby construct.
      #
      # @private
      # @api private
      def self.included(base)
        base.extend ClassMethods
      end
    end
  end
end
