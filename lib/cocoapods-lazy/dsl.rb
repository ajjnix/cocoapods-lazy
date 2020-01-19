require 'cocoapods'
require 'cocoapods-lazy/logger'

module Pod
  class Podfile
    module DSL
      class Config
        attr_accessor :base_url
        
        def validate
          raise 'Write base_url for continue' if base_url == nil
        end
        
        def login
          return @login unless @login.nil?
          Pod::Lazy::Logger.important "Write login from #{@base_url}"
          @login = $stdin.gets
          return @login
        end
        
        def login=(login)
          @login = Shellwords.escape(login) unless login.blank?
        end
        
        def password
          return @password unless @password.nil?
          Pod::Lazy::Logger.important "Write password from #{@base_url}"
          @password = Shellwords.escape $stdin.gets.chomp
          return @password
        end
        
        def password=(password)
          @password = Shellwords.escape(password) unless password.blank?
        end
        
        def to_s
          descriptor = ""
          descriptor += "login = #{@login}\n" unless @login.nil?
          descriptor += "password = *****\n" unless @password.nil?
          descriptor += "base_url = #{@base_url}"
        end
      end
    end
  end
end

module Pod
  class Podfile
    module DSL
      class_attr_accessor :config

      def cocoapods_lazy(&block)
        config = Config.new()
        block.call(config)
        config.validate
        DSL.config = config
      end
    end
  end
end
