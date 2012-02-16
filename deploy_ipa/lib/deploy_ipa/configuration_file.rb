require 'deploy_ipa/application'
require 'deploy_ipa/identity'
require 'deploy_ipa/store'
require 'kwalify'

class ConfigurationFile
  attr_accessor :identities
  attr_accessor :stores
  attr_accessor :applications
  
  def initialize(fileName)
    # Load YAML schema
   schemaFile = Kwalify::Yaml.load_file('lib/deploy_ipa/configuration_file_schema.yaml')
   validator = Kwalify::Validator.new(schemaFile)
    
    # Load and validate YAML file
    fileContents = Kwalify::Yaml.load_file(fileName)
    errors = validator.validate(fileContents)
    if errors && ! errors.empty?
      for error in errors
        puts("[#{error.path}] #{error.message}")
      end
      raise StandardError, 'The configuration file ' + fileName + ' contains errors'
    end
        
    # Extract data
    @identitiesMap = {}
    fileContents['identities'].each { |identityData|
      identity = Identity.new(identityData, self)
      @identitiesMap[identity.name] = identity
    }
    
    @storesMap = {}
    fileContents['stores'].each { |storeData|
      store = Store.new(storeData, self)
      @storesMap[store.name] = store
    }
    
    @applicationsMap = {}
    fileContents['applications'].each { |applicationData|
      application = Application.new(applicationData, self)
      @applicationsMap[application.name] = application
    }
  end
  
  def identityNames
    return @identitiesMap.keys
  end
  
  def identities
    return @identitiesMap.values
  end
  
  def identity(name)
    return @identitiesMap[name]
  end
  
  def storeNames
    return @storesMap.keys
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
  
  def applicationNames
    return @applicationsMap.keys
  end
  
  def application(name)
    return @applicationsMap[name]
  end
end