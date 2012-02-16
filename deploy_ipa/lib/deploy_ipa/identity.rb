require 'deploy_ipa/configuration_file'

class Identity
  attr_accessor :name
  attr_accessor :provisioning_profile
  attr_accessor :code_signing_identity
  
  def initialize(data, configuration_file)
    @name = data['name']
    @provisioning_profile = data['provisioning_profile']
    @code_signing_identity = data['code_signing_identity']
    @configuration_file = configuration_file
  end
end