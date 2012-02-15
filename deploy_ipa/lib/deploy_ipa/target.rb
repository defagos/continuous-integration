require 'configuration_file'

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