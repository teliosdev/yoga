require "yoga/expression/lexer"
require "yoga/expression/parser"
require "yoga/expression/compiler"
require "yoga/expression/definitions"

module Yoga
  class Expression
    include Lexer
    include Parser
    include Compiler
    include Definitions

    def initialize(body, definitions = {})
      @body = body
      @definitions = definitions
    end

    def build!
      @out = parse(scan)
    end
  end
end
