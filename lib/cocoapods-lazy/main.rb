require 'cocoapods'
require 'cocoapods-core/podfile'
require 'cocoapods-lazy/version'
require 'cocoapods-lazy/logger'
require 'cocoapods-lazy/repository'
require 'cocoapods-lazy/remote_storage'
require 'cocoapods-lazy/dsl'

module Pod
  module Lazy
    def initialize(argv)
      super
      @should_store = argv.flag?('store', true)
      @should_fetch = argv.flag?('fetch', true)
    end

    def run
      Logger.info "Redirection to cocoapods-lazy"
      lazy_config = load_credential()
      unless lazy_config.nil?
        Logger.info "cocoapods-lazy is enabled in Podfile"
        Logger.info "Lazy config:\n#{lazy_config}"
        remote_storage = Pod::Lazy::RemoteStorage.new(lazy_config)
        repository = Pod::Lazy::Repository.new(remote_storage)
        repository.fetch() if @should_fetch
        Logger.info "Run origin command"
        super
        if repository.should_store && @should_store
          Logger.info "Storing..."
          repository.store()
        end
        Logger.info "Flow cocoapods-lazy if finished"
      else
        Logger.info "cocoapods-lazy is not enabled in Podfile"
        Logger.info "Run origin command"
        super
      end
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
      Pod::Podfile::DSL.config
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
