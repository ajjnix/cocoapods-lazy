require 'cocoapods-lazy/version'
require 'cocoapods-lazy/podfile_lock'
require 'cocoapods-lazy/repository'
require 'cocoapods'

module CocoapodsLazy
  class Invoker
    def self.invoke(argv)
      use_case = UseCase.new()
      case
      when argv.include?('install')
        use_case.install
      when argv.include?('update')
        use_case.update()
      when argv.include?('store')
        use_case.store()
      else
        raise "Unknown command!"
      end
    end
  end
  
  class UseCase
    def initialize()
      @repository = Repository.new("PodStore.env")
    end

    def install
      puts "Check local prebuild"
      if read_podfile_checksum() != read_manifest_checksum()
        puts 'Drop pods'
        `rm -rf Pods`
        @repository.download(name: read_podfile_checksum())
      else
        puts 'Pods is actual'
      end
      Pod::Command.run(ARGV)
      store() if read_podfile_checksum() != read_manifest_checksum()
    end
    
    def update
      Pod::Command.run(ARGV)
      store()
    end

    def store
      @repository.upload(name: read_podfile_checksum())
    end

    private

    def read_podfile_checksum
      PodfileLock.new("Podfile.lock").checksum
    end

    def read_manifest_checksum
      PodfileLock.new("./Pods/Manifest.lock").checksum
    end
  end
end
