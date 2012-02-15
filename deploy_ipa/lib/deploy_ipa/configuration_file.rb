require 'application'
require 'identity'
require 'store'
require 'yaml'

class ConfigurationFile
  def initialize(fileName)
    fileContents = YAML.load_file(fileName)
    # TODO: Check errors (syntax, file existence, etc.)
    
    fileContents['identities'].each { | identityData |
      identity = Identity.new(identityData)
    }
    
    fileContents['stores'].each { | storeData |
      store = Store.new(storeData)
    }
    
    fileContents['applications'].each { | applicationData |
      application = Application.new(applicationData)
    }
  end
end