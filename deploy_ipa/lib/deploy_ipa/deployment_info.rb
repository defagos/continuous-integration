class DeploymentInfo
  attr_accessor :application_name
  attr_accessor :store_name
  attr_accessor :identity_name
  
  def initialize(application_name, store_name, identity_name)
    @application_name = application_name
    @store_name = store_name
    @identity_name = identity_name
  end
end