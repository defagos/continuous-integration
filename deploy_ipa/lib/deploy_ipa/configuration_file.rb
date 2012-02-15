require 'application'
require 'identity'
require 'store'
require 'yaml'

class ConfigurationFile
  # Constructor
  def initialize(fileName)
    # Parse YAML configuration file
    fileContents = YAML.load_file(fileName)
    
    # Extract configuration data
    @identities = {}
    fileContents['identities'].each { | identityData |
      identity = Identity.new(identityData)
      @identities[identity.name] = identity
    }
    
    @stores = {}
    fileContents['stores'].each { | storeData |
      store = Store.new(storeData)
      @stores[store.name] = store
    }
    
    @applications = {}
    fileContents['applications'].each { | applicationData |
      application = Application.new(applicationData)
      @applications[application.name] = application
    }
  end
  
  # Return the identity matching a given name
  def identity(name)
    return @identities[name]
  end
  
  # Return the store matching a given name
  def store(name)
    return @stores[name]
  end
  
  # Return the application matchin a given name
  def application(name)
    return @applications[name]
  end
end