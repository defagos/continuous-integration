require 'application'
require 'identity'
require 'store'
require 'yaml'

class ConfigurationFile
  def initialize(fileName)
    # Parse YAML configuration file
    fileContents = YAML.load_file(fileName)
    
    # Extract configuration data
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