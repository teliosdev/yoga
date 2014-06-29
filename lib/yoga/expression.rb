require "yoga/expression/lexer"
require "yoga/expression/parser"
require "yoga/expression/compiler"

module Yoga

  # Defines an expression that can be used in Yoga.  This parses and
  # compiles an expression.
  class Expression

    include Lexer
    include Parser
    include Compiler

    def initialize(body)
      @body = body
    end

    def build!
      @out = parse(scan)
    end

  end
end
