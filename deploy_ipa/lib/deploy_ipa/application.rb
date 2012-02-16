class Application
  attr_accessor :name
  attr_accessor :repository_url
  attr_accessor :targets
  
  class Target
    attr_accessor :store_name
    attr_accessor :identity_name

    def initialize(data, configuration_file)
      @store_name = data['store_name']
      @identity_name = data['identity_name']
      @configuration_file = configuration_file
    end

    def store
      return @configuration_file.store(@store_name)
    end

    def identity
      return @configuration_file.identity(@identity_name)
    end
  end
  
  def initialize(data, configuration_file)
    @name = data['name']
    @repository_url = data['repository_url']
    
    @targets = []
    data['targets'].each { |target_data|
      target = Target.new(target_data, configuration_file)
      @targets << target
    }
    
    @configuration_file = configuration_file
  end
end