require 'deploy_ipa/configuration_file'

class DeployIpa
  def self.main
    begin
      configurationFile = ConfigurationFile.new("test/data/test_configuration_file1.yaml")
    rescue Exception => error
      puts(error.message)
    end
  end
end