class DeploymentInfo
  attr_accessor :applicationName
  attr_accessor :storeName
  attr_accessor :identityName
  
  def initialize(applicationName, storeName, identityName)
    @applicationName = applicationName
    @storeName = storeName
    @identityName = identityName
  end
end