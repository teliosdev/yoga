# encoding: utf-8
# frozen_string_literal: true

module Fixtures
  class Parser
    class Root < Yoga::Node
      attribute :children, type: [Yoga::Node]
    end

    class Literal < Yoga::Node
      attribute :value, type: ::Integer
    end

    class Identifier < Yoga::Node
      attribute :name, type: ::String
    end

    def parse_root
      statements = collect([:EOF], [:";"]) { parse_statement }
      Root.new(children: statements,
        location: statement.map(&:location).inject(:union))
    end

    def parse_statement
      left = parse_atom

      while peek?([:"+", :"-", :"*", :"/", :"^", :"%", :"="])
        left = parse_expression(left)
      end

      left
    end

    def parse_atom
      if peek?(:NUMERIC)
        Literal.new(value: expect(:NUMERIC).value, location: collect_locations)
      elsif peek?(:"(")
        expect(:"(")
        statement = parse_statement
        expect(:")")
        statement
      else
        Identifier.new(value: expect(:IDENT).value, location: collect_locations)
      end
    end

    switch(:Expression,
      :"=" => proc { |left| Operator.new(kind: :"=", left: left, right: parse_atom, location: collect_locations) },
      :"+" => proc { |left| Operator.new(kind: :"+", left: left, right: parse_atom, location: collect_locations) },
      :"-" => proc { |left| Operator.new(kind: :"-", left: left, right: parse_atom, location: collect_locations) },
      :"*" => proc { |left| Operator.new(kind: :"*", left: left, right: parse_atom, location: collect_locations) },
      :"/" => proc { |left| Operator.new(kind: :"/", left: left, right: parse_atom, location: collect_locations) },
      :"^" => proc { |left| Operator.new(kind: :"^", left: left, right: parse_atom, location: collect_locations) },
      :"%" => proc { |left| Operator.new(kind: :"%", left: left, right: parse_atom, location: collect_locations) })

    def parse_expression(left)
      switch(:Expression, left)
    end
  end
end