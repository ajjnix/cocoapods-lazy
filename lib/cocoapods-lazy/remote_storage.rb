require 'cocoapods-lazy/log'

module Pod
  module Lazy
    class RemoteStorage
      include Pod::Lazy::Log

      def initialize(credential)
        @login = credential.login
        @password = credential.password
        @base_url = credential.base_url
      end

      def fetch(name:)
        zip_name = "#{name}.zip"
        url = @base_url + zip_name
        puts `curl --fail -v -u #{@login}:#{@password} #{url} --output #{zip_name}`
        `unzip #{zip_name}`
        `rm -rf #{zip_name}`
      end

      def store(name:)
        zip_name = "#{name}.zip"
        unless File.exist?(zip_name)
          puts "Make zip: #{zip_name}"
          `zip -9 -r -y #{zip_name} Pods`
        end
        url = @base_url + zip_name
        puts "Storing to #{url}"
        `curl --fail -v -u #{@login}:#{@password} --upload-file #{zip_name} #{url}`
        puts "Remove #{zip_name}"
        `rm -rf #{zip_name}`
      end
    end
  end
end