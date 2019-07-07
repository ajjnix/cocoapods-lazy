require 'cocoapods-core'
require 'fileutils'
require 'cocoapods-lazy/log'

module Pod
  module Lazy
    class Repository
      include Pod::Lazy::Log

      def initialize(repository)
        @repository = repository
      end

      def fetch
        @fetched_checksum = read_podfile_checksum()
        if @fetched_checksum.nil?
          puts "Podfile.lock not found"
          @is_generated_pods = true
        elsif @fetched_checksum != read_manifest_checksum()
          puts 'Checksum IS NOT EQUAL'
          puts 'Drop Pods directory'
          `rm -rf Pods`
          @repository.fetch(name: @fetched_checksum)
          @is_generated_pods = !Dir.exist?('Pods')
        else
          puts 'Checksum IS EQUAL'
          @is_generated_pods = false
        end
      end

      def should_store
        @is_generated_pods || is_modified_pods?
      end

      def store
        puts "Reason for store: #{store_reason || 'Not reason for store'}"
        @repository.store(name: read_podfile_checksum())
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
    end
  end
end
