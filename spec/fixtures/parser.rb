# encoding: utf-8
# frozen_string_literal: true

module Fixtures
  class Parser
    include Yoga::Parser

    class Root < Yoga::Node
      attribute :children, type: [Yoga::Node]
    end

    class Literal < Yoga::Node
      attribute :value, type: ::Integer
    end

    class Identifier < Yoga::Node
      attribute :name, type: ::String
    end

    class Operation < Yoga::Node
      attribute :left, type: Yoga::Node
      attribute :right, type: Yoga::Node
      attribute :kind, type: ::Symbol
    end

    def parse_root
      statements = collect([:EOF], [:";"]) { parse_statement }
      Root.new(children: statements,
        location: statements.map(&:location).inject(:union))
    end

    def parse_statement
      fail if peek?([:EOF])
      left = parse_atom

      while peek?([:"+", :"-", :"*", :"/", :"^", :"%", :"="])
        left = parse_expression(left)
      end

      left
    end

    def parse_atom
      if peek?([:NUMERIC])
        numeric = expect([:NUMERIC])
        Literal.new(value: numeric.value, location: numeric.location)
      elsif peek?([:"("])
        expect([:"("])
        statement = parse_statement
        expect([:")"])
        statement
      else
        ident = expect(Set[:IDENT])
        Identifier.new(name: ident.value, location: ident.location)
      end
    end

    switch(:Expression,
      "=": proc { |left| parse_operation(:"=", left) },
      "+": proc { |left| parse_operation(:"+", left) },
      "-": proc { |left| parse_operation(:"-", left) },
      "*": proc { |left| parse_operation(:"*", left) },
      "/": proc { |left| parse_operation(:"/", left) },
      "^": proc { |left| parse_operation(:"^", left) },
      "%": proc { |left| parse_operation(:"%", left) })

    def parse_expression(left)
      switch(:Expression, left)
    end

    def parse_operation(symbol, left)
      operator = expect([symbol])
      right = parse_atom
      location = operator.location.union(left.location, right.location)
      Operation.new(kind: symbol, left: left, right: right,
        location: location)
    end
  end
end
