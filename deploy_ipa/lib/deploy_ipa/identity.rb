require 'configuration_file'

class Identity
  attr_accessor :name
  attr_accessor :provisioningProfile
  attr_accessor :codeSigningIdentity
  
  def initialize(data, configurationFile)
    @name = data['name']
    @provisioningProfile = data['provisioning_profile']
    @codeSigningIdentity = data['code_signing_identity']
    @configurationFile = configurationFile
  end
end