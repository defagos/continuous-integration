class Identity
  attr_accessor :name
  attr_accessor :provisioningProfile
  attr_accessor :codeSigningIdentity
  
  def initialize(data)
    @name = data['name']
    @provisioningProfile = data['provisioning_profile']
    @codeSigningIdentity = data['code_signing_identity']
  end
end