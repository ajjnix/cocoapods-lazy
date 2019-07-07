require 'cocoapods'
require 'cocoapods-lazy/credential'

module Pod
  class Podfile
    module DSL
      class Credential
        attr_accessor :login
        attr_accessor :password
        attr_accessor :base_url
        
        def is_valid?
          return login != nil && password != nil && base_url != nil
        end
      end
    end
  end
end

module Pod
  class Podfile
    module DSL
      class_attr_accessor :credential

      def pods_storage_credential(&block)
        credential = Credential.new()
        block.call(credential)
        raise unless credential.is_valid?
        DSL.credential = Pod::Lazy::Credential.new(credential.login, credential.password, credential.base_url)
      end
    end
  end
end
