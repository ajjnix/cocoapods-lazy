require 'cocoapods'
require 'cocoapods-lazy/version'
require 'cocoapods-lazy/log'
require 'cocoapods-lazy/repository'
require 'cocoapods-lazy/remote_storage'
require 'cocoapods-lazy/dsl'
require 'cocoapods-core/podfile'

module Pod
  module Lazy
    def initialize(argv)
      super
      @should_store = argv.flag?('store', true)
      @should_fetch = argv.flag?('fetch', true)
    end

    def run
      puts "Redirection to cocoapods-lazy"
      credential = load_credential()
      unless credential.nil?
        puts "cocoapods-lazy is enabled in Podfile"
        puts "Credentials:\n#{credential}"
        remote_storage = Pod::Lazy::RemoteStorage.new(credential)
        repository = Pod::Lazy::Repository.new(remote_storage)
        repository.fetch() if @should_fetch
        puts "Run 'pod #{ARGV.join(" ")}'"
        super
        if repository.should_store && @should_store
          puts "Storing..."
          repository.store()
        end
        puts "Flow cocoapods-lazy if finished"
      else
        puts "cocoapods-lazy is not enabled in Podfile"
        puts "Run cocoapods #{ARGV}"
        super
      end
    end

    def puts(value)
      Pod::Lazy::Log.puts(value)
    end

    def options
      [
        ['--no-fetch', 'Skip fetch action'], 
        ['--no-store', 'Skip store action'],
      ].concat(super)
    end

    private
    
    def load_credential
      path = Pathname.new('Podfile')
      Podfile.from_file(path)
      Pod::Podfile::DSL.credential
    end
  end
end

class Pod::Command::Install
  prepend Pod::Lazy
end

class Pod::Command::Update
  prepend Pod::Lazy
end

Pod::Command::Install.singleton_class.prepend Pod::Lazy
Pod::Command::Update.singleton_class.prepend Pod::Lazy

# Pod::Command::Install.singleton_class.send :prepend, Pod::Lazy
# Pod::Command::Update.singleton_class.send :prepend, Pod::Lazy
