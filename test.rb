$LOAD_PATH << File.expand_path("../lib", __FILE__)
require "yoga"
require "terminal-table"

#exp = Yoga::Expression.new(%q{[a-z]+ ":" ( any* -- "\r\n" ) "\r\n"})
#exp = Yoga::Expression.new(%q{(('0x' [0-9a-fA-F]+) | ([0-9]+) | ([A-Za-z][A-Za-z0-9]*))})
exp = Yoga::Expression.new(%q{([^bcd]* ('b' |('c' 'd'?))+)})

machine = exp.build!
machine.each_with_index do |mach, i|
  mach.minimize!
  mach.to_dot("machine-#{i}")
  mach.determinitize.to_dot("machine-#{i}-determinitized")
end

m = machine[0].determinitize.minimize_nondistinct!.minimize!
m.to_dot('test')

m.run_on("aaaabbbbcdcdcd")
