

module Yoga
  class Expression
    module Parser
      # This file assumes that the output of the generator will be placed
# within a module or a class.  However, the module/class requires a
# `type` method, which takes a terminal and gives its type, as a
# symbol.  These types should line up with the terminals that were
# defined in the original grammar.

# The actions to take during parsing.  In every state, there are a
# set of acceptable peek tokens; this table tells the parser what
# to do on each acceptable peek token.  The possible actions include
# `:accept`, `:reduce`, and `:state`; `:accept` means to accept the
# input and return the value of the pasing.  `:reduce` means to
# reduce the top of the stack into a given nonterminal.  `:state`
# means to transition to another state.
#
# @return [Array<Hash<(Symbol, Array<(Symbol, Numeric)>)>>]
ACTION_TABLE = [{:expression=>[:state, 1],
  :group=>[:state, 2],
  :value=>[:state, 3],
  :LPAREN=>[:state, 4],
  :STRING=>[:state, 5],
  :CONTAIN=>[:state, 6],
  :NUMBER=>[:state, 7],
  :IDENTIFIER=>[:state, 8]},
 {:"$"=>[:state, 9]},
 {:expression=>[:state, 10],
  :group=>[:state, 2],
  :value=>[:state, 3],
  :LPAREN=>[:state, 4],
  :STRING=>[:state, 5],
  :CONTAIN=>[:state, 6],
  :NUMBER=>[:state, 7],
  :IDENTIFIER=>[:state, 8],
  :modifier=>[:state, 11],
  :STAR=>[:state, 12],
  :PLUS=>[:state, 13],
  :OPTIONAL=>[:state, 14],
  :binop=>[:state, 15],
  :UNION=>[:state, 16],
  :INTERSECT=>[:state, 17],
  :SDIFFERENCE=>[:state, 18],
  :DIFFERENCE=>[:state, 19],
  :"$"=>[:reduce, 1],
  :RPAREN=>[:reduce, 1]},
 {:"$"=>[:reduce, 5],
  :STAR=>[:reduce, 5],
  :PLUS=>[:reduce, 5],
  :OPTIONAL=>[:reduce, 5],
  :UNION=>[:reduce, 5],
  :INTERSECT=>[:reduce, 5],
  :SDIFFERENCE=>[:reduce, 5],
  :DIFFERENCE=>[:reduce, 5],
  :LPAREN=>[:reduce, 5],
  :STRING=>[:reduce, 5],
  :CONTAIN=>[:reduce, 5],
  :NUMBER=>[:reduce, 5],
  :IDENTIFIER=>[:reduce, 5],
  :RPAREN=>[:reduce, 5]},
 {:expression=>[:state, 20],
  :group=>[:state, 2],
  :value=>[:state, 3],
  :LPAREN=>[:state, 4],
  :STRING=>[:state, 5],
  :CONTAIN=>[:state, 6],
  :NUMBER=>[:state, 7],
  :IDENTIFIER=>[:state, 8]},
 {:"$"=>[:reduce, 14],
  :STAR=>[:reduce, 14],
  :PLUS=>[:reduce, 14],
  :OPTIONAL=>[:reduce, 14],
  :UNION=>[:reduce, 14],
  :INTERSECT=>[:reduce, 14],
  :SDIFFERENCE=>[:reduce, 14],
  :DIFFERENCE=>[:reduce, 14],
  :LPAREN=>[:reduce, 14],
  :STRING=>[:reduce, 14],
  :CONTAIN=>[:reduce, 14],
  :NUMBER=>[:reduce, 14],
  :IDENTIFIER=>[:reduce, 14],
  :RPAREN=>[:reduce, 14]},
 {:"$"=>[:reduce, 15],
  :STAR=>[:reduce, 15],
  :PLUS=>[:reduce, 15],
  :OPTIONAL=>[:reduce, 15],
  :UNION=>[:reduce, 15],
  :INTERSECT=>[:reduce, 15],
  :SDIFFERENCE=>[:reduce, 15],
  :DIFFERENCE=>[:reduce, 15],
  :LPAREN=>[:reduce, 15],
  :STRING=>[:reduce, 15],
  :CONTAIN=>[:reduce, 15],
  :NUMBER=>[:reduce, 15],
  :IDENTIFIER=>[:reduce, 15],
  :RPAREN=>[:reduce, 15]},
 {:"$"=>[:reduce, 16],
  :STAR=>[:reduce, 16],
  :PLUS=>[:reduce, 16],
  :OPTIONAL=>[:reduce, 16],
  :UNION=>[:reduce, 16],
  :INTERSECT=>[:reduce, 16],
  :SDIFFERENCE=>[:reduce, 16],
  :DIFFERENCE=>[:reduce, 16],
  :LPAREN=>[:reduce, 16],
  :STRING=>[:reduce, 16],
  :CONTAIN=>[:reduce, 16],
  :NUMBER=>[:reduce, 16],
  :IDENTIFIER=>[:reduce, 16],
  :RPAREN=>[:reduce, 16]},
 {:"$"=>[:reduce, 17],
  :STAR=>[:reduce, 17],
  :PLUS=>[:reduce, 17],
  :OPTIONAL=>[:reduce, 17],
  :UNION=>[:reduce, 17],
  :INTERSECT=>[:reduce, 17],
  :SDIFFERENCE=>[:reduce, 17],
  :DIFFERENCE=>[:reduce, 17],
  :LPAREN=>[:reduce, 17],
  :STRING=>[:reduce, 17],
  :CONTAIN=>[:reduce, 17],
  :NUMBER=>[:reduce, 17],
  :IDENTIFIER=>[:reduce, 17],
  :RPAREN=>[:reduce, 17]},
 {:"$"=>[:accept, 0]},
 {:"$"=>[:reduce, 2], :RPAREN=>[:reduce, 2]},
 {:"$"=>[:reduce, 3],
  :STAR=>[:reduce, 3],
  :PLUS=>[:reduce, 3],
  :OPTIONAL=>[:reduce, 3],
  :UNION=>[:reduce, 3],
  :INTERSECT=>[:reduce, 3],
  :SDIFFERENCE=>[:reduce, 3],
  :DIFFERENCE=>[:reduce, 3],
  :LPAREN=>[:reduce, 3],
  :STRING=>[:reduce, 3],
  :CONTAIN=>[:reduce, 3],
  :NUMBER=>[:reduce, 3],
  :IDENTIFIER=>[:reduce, 3],
  :RPAREN=>[:reduce, 3]},
 {:"$"=>[:reduce, 6],
  :STAR=>[:reduce, 6],
  :PLUS=>[:reduce, 6],
  :OPTIONAL=>[:reduce, 6],
  :UNION=>[:reduce, 6],
  :INTERSECT=>[:reduce, 6],
  :SDIFFERENCE=>[:reduce, 6],
  :DIFFERENCE=>[:reduce, 6],
  :LPAREN=>[:reduce, 6],
  :STRING=>[:reduce, 6],
  :CONTAIN=>[:reduce, 6],
  :NUMBER=>[:reduce, 6],
  :IDENTIFIER=>[:reduce, 6],
  :RPAREN=>[:reduce, 6]},
 {:"$"=>[:reduce, 7],
  :STAR=>[:reduce, 7],
  :PLUS=>[:reduce, 7],
  :OPTIONAL=>[:reduce, 7],
  :UNION=>[:reduce, 7],
  :INTERSECT=>[:reduce, 7],
  :SDIFFERENCE=>[:reduce, 7],
  :DIFFERENCE=>[:reduce, 7],
  :LPAREN=>[:reduce, 7],
  :STRING=>[:reduce, 7],
  :CONTAIN=>[:reduce, 7],
  :NUMBER=>[:reduce, 7],
  :IDENTIFIER=>[:reduce, 7],
  :RPAREN=>[:reduce, 7]},
 {:"$"=>[:reduce, 8],
  :STAR=>[:reduce, 8],
  :PLUS=>[:reduce, 8],
  :OPTIONAL=>[:reduce, 8],
  :UNION=>[:reduce, 8],
  :INTERSECT=>[:reduce, 8],
  :SDIFFERENCE=>[:reduce, 8],
  :DIFFERENCE=>[:reduce, 8],
  :LPAREN=>[:reduce, 8],
  :STRING=>[:reduce, 8],
  :CONTAIN=>[:reduce, 8],
  :NUMBER=>[:reduce, 8],
  :IDENTIFIER=>[:reduce, 8],
  :RPAREN=>[:reduce, 8]},
 {:group=>[:state, 21],
  :value=>[:state, 3],
  :LPAREN=>[:state, 4],
  :STRING=>[:state, 5],
  :CONTAIN=>[:state, 6],
  :NUMBER=>[:state, 7],
  :IDENTIFIER=>[:state, 8]},
 {:STAR=>[:reduce, 9],
  :PLUS=>[:reduce, 9],
  :OPTIONAL=>[:reduce, 9],
  :UNION=>[:reduce, 9],
  :INTERSECT=>[:reduce, 9],
  :SDIFFERENCE=>[:reduce, 9],
  :DIFFERENCE=>[:reduce, 9],
  :LPAREN=>[:reduce, 9],
  :STRING=>[:reduce, 9],
  :CONTAIN=>[:reduce, 9],
  :NUMBER=>[:reduce, 9],
  :IDENTIFIER=>[:reduce, 9]},
 {:STAR=>[:reduce, 10],
  :PLUS=>[:reduce, 10],
  :OPTIONAL=>[:reduce, 10],
  :UNION=>[:reduce, 10],
  :INTERSECT=>[:reduce, 10],
  :SDIFFERENCE=>[:reduce, 10],
  :DIFFERENCE=>[:reduce, 10],
  :LPAREN=>[:reduce, 10],
  :STRING=>[:reduce, 10],
  :CONTAIN=>[:reduce, 10],
  :NUMBER=>[:reduce, 10],
  :IDENTIFIER=>[:reduce, 10]},
 {:STAR=>[:reduce, 11],
  :PLUS=>[:reduce, 11],
  :OPTIONAL=>[:reduce, 11],
  :UNION=>[:reduce, 11],
  :INTERSECT=>[:reduce, 11],
  :SDIFFERENCE=>[:reduce, 11],
  :DIFFERENCE=>[:reduce, 11],
  :LPAREN=>[:reduce, 11],
  :STRING=>[:reduce, 11],
  :CONTAIN=>[:reduce, 11],
  :NUMBER=>[:reduce, 11],
  :IDENTIFIER=>[:reduce, 11]},
 {:STAR=>[:reduce, 12],
  :PLUS=>[:reduce, 12],
  :OPTIONAL=>[:reduce, 12],
  :UNION=>[:reduce, 12],
  :INTERSECT=>[:reduce, 12],
  :SDIFFERENCE=>[:reduce, 12],
  :DIFFERENCE=>[:reduce, 12],
  :LPAREN=>[:reduce, 12],
  :STRING=>[:reduce, 12],
  :CONTAIN=>[:reduce, 12],
  :NUMBER=>[:reduce, 12],
  :IDENTIFIER=>[:reduce, 12]},
 {:RPAREN=>[:state, 22]},
 {:modifier=>[:state, 11],
  :STAR=>[:state, 12],
  :PLUS=>[:state, 13],
  :OPTIONAL=>[:state, 14],
  :binop=>[:state, 15],
  :UNION=>[:state, 16],
  :INTERSECT=>[:state, 17],
  :SDIFFERENCE=>[:state, 18],
  :DIFFERENCE=>[:state, 19],
  :"$"=>[:reduce, 4],
  :LPAREN=>[:reduce, 4],
  :STRING=>[:reduce, 4],
  :CONTAIN=>[:reduce, 4],
  :NUMBER=>[:reduce, 4],
  :IDENTIFIER=>[:reduce, 4],
  :RPAREN=>[:reduce, 4]},
 {:"$"=>[:reduce, 13],
  :STAR=>[:reduce, 13],
  :PLUS=>[:reduce, 13],
  :OPTIONAL=>[:reduce, 13],
  :UNION=>[:reduce, 13],
  :INTERSECT=>[:reduce, 13],
  :SDIFFERENCE=>[:reduce, 13],
  :DIFFERENCE=>[:reduce, 13],
  :LPAREN=>[:reduce, 13],
  :STRING=>[:reduce, 13],
  :CONTAIN=>[:reduce, 13],
  :NUMBER=>[:reduce, 13],
  :IDENTIFIER=>[:reduce, 13],
  :RPAREN=>[:reduce, 13]}]
.freeze # >

# A list of all of the productions.  Only includes the left-hand side,
# the number of tokens on the right-hand side, and the block to call
# on reduction.
#
# @return [Array<Array<(Symbol, Numeric, Proc)>>]
PRODUCTIONS  = [[:$start, 2, proc { |_| _ }],
[:expression, 1, proc { |_| [_]       }],
[:expression, 2, proc { |a, b| b.unshift(a) }],
[:group, 2, proc { |a, b| [b, a] }],
[:group, 3, proc { |a, b, c| compile_binop(b, a, c) }],
[:group, 1, proc { |_| _ }],
[:modifier, 1, proc { |_| _[0] }],
[:modifier, 1, proc { |_| _[0] }],
[:modifier, 1, proc { |_| _[0] }],
[:binop, 1, proc { |_| _[0] }],
[:binop, 1, proc { |_| _[0] }],
[:binop, 1, proc { |_| _[0] }],
[:binop, 1, proc { |_| _[0] }],
[:value, 3, proc { |_, a, _| a }],
[:value, 1, proc { |_| compile_string(_)  }],
[:value, 1, proc { |_| compile_contain(_) }],
[:value, 1, proc { |_| compile_number(_)  }],
[:value, 1, proc { |_| _ }]].freeze # >

# Runs the parser.
#
# @param input [Array<Object>] the input to run the parser over.
# @return [Object] the result of the accept.
def parse(input)
  stack = []
  stack.push([nil, 0])
  input = input.dup
  last  = nil

  until stack.empty? do
    peek_token = if input.empty?
      :"$"
    else
      type(input.first)
    end

    action = ACTION_TABLE[stack.last.last].fetch(peek_token)
    case action.first
    when :accept
      production = PRODUCTIONS[action.last]
      last       = stack.pop(production[1]).first.first
      stack.pop
    when :reduce
      production = PRODUCTIONS[action.last]
      removing   = stack.pop(production[1])
      value = instance_exec(*removing.map(&:first), &production[2])
      goto  = ACTION_TABLE[stack.last.last][production[0]]
      stack.push([value, goto.last])
    when :state
      stack.push([input.shift, action.last])
    else
      raise
    end
  end

  last
end


      def type(token)
        token[0].to_s.upcase.intern
      end
    end
  end
end
