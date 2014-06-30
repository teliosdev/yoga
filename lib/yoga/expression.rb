require "yoga/expression/lexer"
require "yoga/expression/parser"
require "yoga/expression/compiler"

module Yoga
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
