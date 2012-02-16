class Application
  attr_accessor :name
  attr_accessor :repositoryURL
  attr_accessor :targets
  
  class Target
    attr_accessor :storeName
    attr_accessor :identityName

    def initialize(data, configurationFile)
      @storeName = data['store_name']
      @identityName = data['identity_name']
      @configurationFile = configurationFile
    end

    def store
      return @configurationFile.store(@storeName)
    end

    def identity
      return @configurationFile.identity(@identityName)
    end
  end
  
  def initialize(data, configurationFile)
    @name = data['name']
    @repositoryURL = data['repository_url']
    
    @targets = []
    data['targets'].each { |targetData|
      target = Target.new(targetData, configurationFile)
      @targets << target
    }
    
    @configurationFile = configurationFile
  end
end