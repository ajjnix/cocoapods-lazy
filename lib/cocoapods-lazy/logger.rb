module Pod
  module Lazy
    class Logger
      def self.info(value)
        UI.puts "#### #{value}".ansi.blue
      end
      
      def self.important(value)
        UI.puts "#### #{value}".ansi.magenta
      end
    end
  end
end
