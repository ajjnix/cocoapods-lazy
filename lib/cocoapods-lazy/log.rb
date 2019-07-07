module Pod
  module Lazy
    module Log
      def puts(value)
        Log.puts(value)
      end
      
      def self.puts(value)
        UI.puts "#### #{value}"
      end
    end
  end
end