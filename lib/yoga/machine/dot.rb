require "erb"

module Yoga
  class Machine
    module Dot

      def dot(out = "machine")
        src_file = File.expand_path("../machine.erb", __FILE__)
        src = File.open(src_file, "r")
        context = instance_eval('binding')
        content = ERB.new(src.read, nil, "-").result(context)

        File.open("#{out}.dot", "w") { |f| f.write(content) }
      end
    end
  end
end
