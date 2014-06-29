require "yoga/expression/lexer"
require "yoga/expression/parser"
require "yoga/expression/compiler"
require "yoga/expression/default_expressions"

module Yoga

  # Defines an expression that can be used in Yoga.  This parses and
  # compiles an expression.
  class Expression

    include Lexer
    include Parser
    include Compiler
    include DefaultExpressions

    def initialize(body, definitions = {})
      @body = body
      @definitions = definitions
    end

    def build!
      @out = parse(scan)
    end

  end
end
