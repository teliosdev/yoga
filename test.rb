$LOAD_PATH << File.expand_path("../lib", __FILE__)
require "yoga"

#exp = Yoga::Expression.new(%q{[a-z]+ ":" ( any* -- "\r\n" ) "\r\n"})
exp = Yoga::Expression.new(%q{"\r\n"})

machine = exp.build!
machine.each_with_index do |mach, i|
  mach.to_dot("machine-#{i}")
end
