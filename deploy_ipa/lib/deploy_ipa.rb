require 'deploy_ipa/configuration_file'
require 'optparse'

class DeployIpa
  def self.run
    options = {}
    OptionParser.new do |parser|
      parser.banner = 'Usage: deploy_ipa [options] configuration_file.yaml'
      
      # Version
      parser.on('-v', '--version', 'Display the version information') do |enabled|
        options[:version] = enabled
      end
      
      # Application list
      applicationNames = []
      parser.on('-a', '--applications LIST', Array, 'A comma-separated list of the applications to deploy (all if omitted)') do |applicationNames|
        options[:applicationNames] = applicationNames
      end
      
      # Identity list
      identityNames = []
      parser.on('-i', '--identities LIST', Array, 'A comma-separated list of the identities to deploy applications for (all if omitted)') do |identityNames|
        options[:identityNames] = identityNames
      end
      
      # Store list
      storeNames = []
      parser.on('-s', '--stores LIST', Array, 'A comma-separated list of the stores to deploy applications to (all if omitted)') do |storeNames|
        options[:storeNames] = storeNames
      end
    end.parse!
    
    p ARGV
    
    
    
    # begin
    #   configurationFile = ConfigurationFile.new('test/data/test_configuration_file1.yaml')
    #   
    #   configurationFile.applications.each { |application|
    #     puts(application.name)
    #     application.targets.each { |target|
    #       puts('  ' + target.store.name + ' -> ' + target.identity.name)
    #     }
    #   }
    # rescue Exception => error
    #   puts(error.message)
    # end
  end
end