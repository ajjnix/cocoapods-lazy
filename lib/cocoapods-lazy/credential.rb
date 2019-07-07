require 'shellwords'

module Pod
  module Lazy
    class Decoder
      def self.decode(string)
        string[0] = '' if string[0] == '$'
        value = ENV[string] || string
        Shellwords.escape(value)
      end
    end

    class Credential
      attr_reader :login
      attr_reader :password
      attr_reader :base_url
      
      def initialize(login, password, base_url)
        @login = Decoder.decode(login)
        @password = Decoder.decode(password)
        @base_url = Decoder.decode(base_url)
      end

      def to_s
        "login = #{@login} \npassword = #{@password} \nbase_url = #{@base_url}"
      end
    end
  end
end
