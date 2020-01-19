require 'cocoapods-lazy/logger'

module Pod
  module Lazy
    class RemoteStorage
      def initialize(config)
        @config = config
      end

      def fetch(name:)
        zip_name = "#{name}.zip"
        url = @config.base_url + zip_name
        `curl --fail #{url} --output #{zip_name}`
        `unzip #{zip_name}`
        `rm -rf #{zip_name}`
      end

      def store(name:)
        zip_name = "#{name}.zip"
        unless File.exist?(zip_name)
          Pod::Lazy::Logger.info "Make zip: #{zip_name}"
          `zip -9 -r -y #{zip_name} Pods`
        end
        url = @config.base_url + zip_name
        Pod::Lazy::Logger.info "Storing to #{url}"
        `curl --fail -u #{@config.login}:#{@config.password} --upload-file #{zip_name} #{url}`
        Pod::Lazy::Logger.info "Remove #{zip_name}"
        `rm -rf #{zip_name}`
      end
    end
  end
end
