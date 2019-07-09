module Pod
  module Lazy
    module Log
      def self.puts(value)
        UI.puts "#### #{value}"
      end
    end
  end
end
