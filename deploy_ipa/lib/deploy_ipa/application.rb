require 'Target'

class Application
  attr_accessor :name
  attr_accessor :repositoryURL
  attr_accessor :targets
  
  def initialize(data, configurationFile)
    @name = data['name']
    @repositoryURL = data['repository_url']
    
    @targets = []
    data['targets'].each { | targetData |
      target = Target.new(targetData, configurationFile)
      @targets << target
    }
    
    @configurationFile = configurationFile
  end
end