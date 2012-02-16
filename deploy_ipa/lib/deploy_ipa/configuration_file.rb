require 'deploy_ipa/application'
require 'deploy_ipa/identity'
require 'deploy_ipa/store'
require 'kwalify'

class ConfigurationFile
  attr_accessor :identities
  attr_accessor :stores
  attr_accessor :applications
  
  def initialize(file_name)
    # Load YAML schema
    configuration_file_path = File.join(File.dirname(File.expand_path(__FILE__)), 'configuration_file_schema.yaml')
    schema_file = Kwalify::Yaml.load_file(configuration_file_path)
    validator = Kwalify::Validator.new(schema_file)
    
    # Load and validate YAML file
    file_contents = Kwalify::Yaml.load_file(file_name)
    errors = validator.validate(file_contents)
    if errors && ! errors.empty?
      for error in errors
        puts("[#{error.path}] #{error.message}")
      end
      raise StandardError, 'The configuration file ' + file_name + ' contains errors'
    end
        
    # Extract data
    @identities_map = {}
    file_contents['identities'].each { |identity_data|
      identity = Identity.new(identity_data, self)
      @identities_map[identity.name] = identity
    }
    
    @stores_map = {}
    file_contents['stores'].each { |store_data|
      store = Store.new(store_data, self)
      @stores_map[store.name] = store
    }
    
    @applications_map = {}
    file_contents['applications'].each { |application_data|
      application = Application.new(application_data, self)
      @applications_map[application.name] = application
    }
  end
  
  def identity_names
    return @identities_map.keys
  end
  
  def identities
    return @identities_map.values
  end
  
  def identity(name)
    return @identities_map[name]
  end
  
  def store_names
    return @stores_map.keys
  end
  
  def stores
    return @stores_map.values
  end
  
  def store(name)
    return @stores_map[name]
  end
  
  def applications
    return @applications_map.values
  end
  
  def application_names
    return @applications_map.keys
  end
  
  def application(name)
    return @applications_map[name]
  end
end