$LOAD_PATH << File.expand_path("../lib", __FILE__)
require "yoga"
require "terminal-table"

#exp = Yoga::Expression.new(%q{[a-z]+ ":" ( any* -- "\r\n" ) "\r\n"})
exp = Yoga::Expression.new(%q{(('0x' [0-9a-fA-F]+) | ([0-9]+) | ([A-Za-z][A-Za-z0-9]*))})
#exp = Yoga::Expression.new(%q{([^bcd]* ('b' |('c' 'd'?))+)})
#exp = Yoga::Expression.new(%q{([a-z]+ - ('for' | 'int'))})
#exp = Yoga::Expression.new(%q{(any* - (any* "\r\n" any*))})

machine = exp.build!
machine.determinitize!
machine.minimize!.minimize_nondistinct!.minimize!
machine.to_dot("machine")
