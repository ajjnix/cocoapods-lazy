# encoding: UTF-8
require 'cocoapods'
require 'cocoapods-lazy/version'
require 'cocoapods-lazy/podfile_lock'
require 'dotenv'
require 'shellwords'

module Pod
  module StoredPods
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

module Pod
  module StoredPods
    class RemoteRepository
      include Pod::StoredPods::Log

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

module Pod
  module StoredPods
    class Repository
      include Pod::StoredPods::Log

      def initialize(repository)
        @repository = repository
      end
      
      def fetch
        @fetched_checksum = read_podfile_checksum()
        if @fetched_checksum != read_manifest_checksum()
          puts 'Checksum IS NOT EQUAL'
          puts 'Drop Pods directory'
          `rm -rf Pods`
          @repository.fetch(name: @fetched_checksum)
        else
          puts 'Checksum IS EQUAL'
        end
        @is_generated_pods = !Dir.exist?('Pods')
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
        PodfileLock.new("Podfile.lock").checksum
      end

      def read_manifest_checksum
        PodfileLock.new("./Pods/Manifest.lock").checksum
      end
    end
  end
end

module Pod
  module StoredPods
    class DSL
      class Credential
        attr_accessor :login
        attr_accessor :password
        attr_accessor :base_url

        def initialize(login, password, base_url)
          @login = login
          @password = password
          @base_url = base_url
        end
      end
      
      def self.credential
        Dotenv.load("PodStore.env")
        login = Shellwords.escape ENV['STORE_USER']
        password = Shellwords.escape ENV['STORE_PASSWORD']
        base_url = ENV['BASE_URL']
        return Credential.new(login, password, base_url)
      end      
    end
  end
end

module Pod
  module ExtensionStoredPods
    def run
      puts "Pod install was redirection to cocoapods-lazy"
      credential = Pod::StoredPods::DSL.credential
      unless credential.nil?
        puts "Invoke cocoapods-lazy flow cause it's enabled in Podfile"
        remote_repository = Pod::StoredPods::RemoteRepository.new(credential)
        repository = Pod::StoredPods::Repository.new(remote_repository)
        repository.fetch()
        puts "Run 'pod #{ARGV.join(" ")}'"
        super
        repository.store() if repository.should_store
        puts "Flow cocoapods-lazy if finished"
      else
        puts "Skip cocoapods-lazy flow cause it's not enabled in Podfile"
        puts "Run cocoapods #{ARGV}"
        super
      end 
    end
    
    def puts(value)
      Pod::StoredPods::Log.puts(value)
    end
  end
end

class Pod::Command::Install
  prepend Pod::ExtensionStoredPods
end



# Pod::HooksManager.register('cocoapods-lazy', :pre_install) do |installer_context|
#   Pod::UI.puts "cocoapods-lazy 🚀🚀🚀🚀🚀"
# end

# module Pod
#     class Podfile
#         module DSL
#
#             # Enable prebuiding for all pods
#             # it has a lower priority to other binary settings
#             def all_binary!
#                 DSL.prebuild_all = true
#             end
#
#             # Enable bitcode for prebuilt frameworks
#             def enable_bitcode_for_prebuilt_frameworks!
#                 DSL.bitcode_enabled = true
#             end
#
#             # Don't remove source code of prebuilt pods
#             # It may speed up the pod install if git didn't
#             # include the `Pods` folder
#             def keep_source_code_for_prebuilt_frameworks!
#                 DSL.dont_remove_source_code = true
#             end
#
#             # Add custom xcodebuild option to the prebuilding action
#             #
#             # You may use this for your special demands. For example: the default archs in dSYMs
#             # of prebuilt frameworks is 'arm64 armv7 x86_64', and no 'i386' for 32bit simulator.
#             # It may generate a warning when building for a 32bit simulator. You may add following
#             # to your podfile
#             #
#             #  ` set_custom_xcodebuild_options_for_prebuilt_frameworks :simulator => "ARCHS=$(ARCHS_STANDARD)" `
#             #
#             # Another example to disable the generating of dSYM file:
#             #
#             #  ` set_custom_xcodebuild_options_for_prebuilt_frameworks "DEBUG_INFORMATION_FORMAT=dwarf"`
#             #
#             #
#             # @param [String or Hash] options
#             #
#             #   If is a String, it will apply for device and simulator. Use it just like in the commandline.
#             #   If is a Hash, it should be like this: { :device => "XXXXX", :simulator => "XXXXX" }
#             #
#             def set_custom_xcodebuild_options_for_prebuilt_frameworks(options)
#                 if options.kind_of? Hash
#                     DSL.custom_build_options = [ options[:device] ] unless options[:device].nil?
#                     DSL.custom_build_options_simulator = [ options[:simulator] ] unless options[:simulator].nil?
#                 elsif options.kind_of? String
#                     DSL.custom_build_options = [options]
#                     DSL.custom_build_options_simulator = [options]
#                 else
#                     raise "Wrong type."
#                 end
#             end
#
#             private
#             class_attr_accessor :prebuild_all
#             prebuild_all = false
#
#             class_attr_accessor :bitcode_enabled
#             bitcode_enabled = false
#
#             class_attr_accessor :dont_remove_source_code
#             dont_remove_source_code = false
#
#             class_attr_accessor :custom_build_options
#             class_attr_accessor :custom_build_options_simulator
#             self.custom_build_options = []
#             self.custom_build_options_simulator = []
#         end
#     end
# end
#
# Pod::HooksManager.register('cocoapods-binary', :pre_install) do |installer_context|
#
#     require_relative 'helper/feature_switches'
#     if Pod.is_prebuild_stage
#         next
#     end
#
#     # [Check Environment]
#     # check user_framework is on
#     podfile = installer_context.podfile
#     podfile.target_definition_list.each do |target_definition|
#         next if target_definition.prebuild_framework_pod_names.empty?
#         if not target_definition.uses_frameworks?
#             STDERR.puts "[!] Cocoapods-binary requires `use_frameworks!`".red
#             exit
#         end
#     end
#
#
#     # -- step 1: prebuild framework ---
#     # Execute a sperated pod install, to generate targets for building framework,
#     # then compile them to framework files.
#     require_relative 'helper/prebuild_sandbox'
#     require_relative 'Prebuild'
#
#     Pod::UI.puts "🚀  Prebuild frameworks"
#
#     # Fetch original installer (which is running this pre-install hook) options,
#     # then pass them to our installer to perform update if needed
#     # Looks like this is the most appropriate way to figure out that something should be updated
#
#     update = nil
#     repo_update = nil
#
#     include ObjectSpace
#     ObjectSpace.each_object(Pod::Installer) { |installer|
#         update = installer.update
#         repo_update = installer.repo_update
#     }
#
#     # control features
#     Pod.is_prebuild_stage = true
#     Pod::Podfile::DSL.enable_prebuild_patch true  # enable sikpping for prebuild targets
#     Pod::Installer.force_disable_integration true # don't integrate targets
#     Pod::Config.force_disable_write_lockfile true # disbale write lock file for perbuild podfile
#     Pod::Installer.disable_install_complete_message true # disable install complete message
#
#     # make another custom sandbox
#     standard_sandbox = installer_context.sandbox
#     prebuild_sandbox = Pod::PrebuildSandbox.from_standard_sandbox(standard_sandbox)
#
#     # get the podfile for prebuild
#     prebuild_podfile = Pod::Podfile.from_ruby(podfile.defined_in_file)
#
#     # install
#     lockfile = installer_context.lockfile
#     binary_installer = Pod::Installer.new(prebuild_sandbox, prebuild_podfile, lockfile)
#
#     if binary_installer.have_exact_prebuild_cache? && !update
#         binary_installer.install_when_cache_hit!
#     else
#         binary_installer.update = update
#         binary_installer.repo_update = repo_update
#         binary_installer.install!
#     end
#
#
#     # reset the environment
#     Pod.is_prebuild_stage = false
#     Pod::Installer.force_disable_integration false
#     Pod::Podfile::DSL.enable_prebuild_patch false
#     Pod::Config.force_disable_write_lockfile false
#     Pod::Installer.disable_install_complete_message false
#     Pod::UserInterface.warnings = [] # clean the warning in the prebuild step, it's duplicated.
#
#
#     # -- step 2: pod install ---
#     # install
#     Pod::UI.puts "\n"
#     Pod::UI.puts "🤖  Pod Install"
#     require_relative 'Integration'
#     # go on the normal install step ...
# end
#
