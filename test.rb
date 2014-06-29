$LOAD_PATH << File.expand_path("../lib", __FILE__)
require "yoga"

exp = Yoga::Expression.new(%q{"hello" | [world]})

machine = exp.build![0]
machine.dot('nfa')
machine.determinitize.determinitize.dot('dfa')
