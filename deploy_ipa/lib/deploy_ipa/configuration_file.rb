require 'application'
require 'identity'
require 'store'
require 'yaml'

class ConfigurationFile
  attr_accessor :identities
  attr_accessor :stores
  attr_accessor :applications
  
  def initialize(fileName)
    fileContents = YAML.load_file(fileName)
    
    @identitiesMap = {}
    fileContents['identities'].each { | identityData |
      identity = Identity.new(identityData, self)
      @identitiesMap[identity.name] = identity
    }
    
    @storesMap = {}
    fileContents['stores'].each { | storeData |
      store = Store.new(storeData, self)
      @storesMap[store.name] = store
    }
    
    @applicationsMap = {}
    fileContents['applications'].each { | applicationData |
      application = Application.new(applicationData, self)
      @applicationsMap[application.name] = application
    }
  end
  
  def identities
    return @identitiesMap.values
  end
  
  def identity(name)
    return @identitiesMap[name]
  end
  
  def stores
    return @storesMap.values
  end
  
  def store(name)
    return @storesMap[name]
  end
  
  def applications
    return @applicationsMap.values
  end
  
  def application(name)
    return @applicationsMap[name]
  end
end