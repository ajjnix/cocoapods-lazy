require 'cocoapods-core'
require 'fileutils'
require 'cocoapods-lazy/logger'

module Pod
  module Lazy
    class Repository
      def initialize(repository)
        @repository = repository
      end

      def fetch
        @fetched_checksum = read_podfile_checksum()
        if @fetched_checksum.nil?
          Logger.info "Podfile.lock not found"
          @is_generated_pods = true
        elsif @fetched_checksum != read_manifest_checksum()
          Logger.info 'Checksum IS NOT EQUAL'
          Logger.info 'Drop Pods directory'
          `rm -rf Pods`
          file_name = add_xcode_version @fetched_checksum
          @repository.fetch(name: file_name)
          @is_generated_pods = !Dir.exist?('Pods')
        else
          Logger.info 'Checksum IS EQUAL'
          @is_generated_pods = false
        end
      end

      def should_store
        @is_generated_pods || is_modified_pods?
      end

      def store
        Logger.info "Reason for store: #{store_reason || 'Not reason for store'}"
        file_name = add_xcode_version @fetched_checksum
        @repository.store(name: file_name)
      end

      private
      
      def is_modified_pods?
        @fetched_checksum != read_manifest_checksum()
      end

      def store_reason
        if @is_generated_pods
          "Pods is generated (not cached) so should be stored"
        elsif is_modified_pods?
          "Manifest is modified so should be stored"
        else
          nil
        end
      end
    
      def read_podfile_checksum
        read_checksum_from_lockfile('Podfile.lock')
      end

      def read_manifest_checksum        
        read_checksum_from_lockfile('./Pods/Manifest.lock')
      end
      
      def read_checksum_from_lockfile(name)
        path = Pathname.new(name)
        return nil unless path.exist?
        lockfile = Lockfile.from_file(path.realpath)
        lockfile.internal_data['PODFILE CHECKSUM']
      end

      def add_xcode_version(name)
          name + "_" + xcode_version
      end

      def xcode_version
          info = `xcodebuild -version`
          info.lines.first.sub!(" ", "_").chomp
      end
    end
  end
end
