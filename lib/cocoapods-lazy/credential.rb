require 'shellwords'

module Pod
  module Lazy
    class Credential
      attr_reader :login
      attr_reader :password
      attr_reader :base_url
      
      def initialize(login, password, base_url)
        @login = Shellwords.escape(login)
        @password = Shellwords.escape(password)
        @base_url = Shellwords.escape(base_url)
      end

      def to_s
        "login = #{@login} \npassword = #{@password} \nbase_url = #{@base_url}"
      end
    end
  end
end
