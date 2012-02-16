require 'deploy_ipa/application'
require 'deploy_ipa/deployment_info'
require 'deploy_ipa/configuration_file'
require 'optparse'

class DeployIpa
  def self.run
    options = {}
    
    # Setup command line parser
    optionParser = OptionParser.new { |parser|
      parser.banner = 'Usage: deploy_ipa [options] configuration_file.yaml'
      parser.version = Gem.loaded_specs["deploy_ipa"].version.to_s
      
      # Application list
      applicationNames = []
      parser.on('-a', '--applications LIST', Array, 'A comma-separated list of the applications to deploy (all if omitted)') { |applicationNames|
        options[:applicationNames] = applicationNames
      }
      
      # Identity list
      identityNames = []
      parser.on('-i', '--identities LIST', Array, 'A comma-separated list of the identities to deploy applications for (all if omitted)') { |identityNames|
        options[:identityNames] = identityNames
      }
      
      # Store list
      storeNames = []
      parser.on('-s', '--stores LIST', Array, 'A comma-separated list of the stores to deploy applications to (all if omitted)') { |storeNames|
        options[:storeNames] = storeNames
      }
    }
    
    # Parse the command line destructively
    success = true
    begin
      optionParser.parse!(ARGV)
    rescue OptionParser::InvalidOption => invalidOptionError
      puts(invalidOptionError.message)
      success = false
    end
    
    # Process remaining arguments (only a YAML file is expected)
    if ARGV.count == 0
      puts('Missing YAML configuration file argument')
      success = false
    elsif ARGV.count > 1
      puts('Too many arguments')
      success = false
    end
    
    # Print help if the command line is incorrect
    if ! success
      puts
      puts(optionParser.help)
      return
    end
    
    # Load the configuration file
    begin
      configurationFile = ConfigurationFile.new(ARGV[0])
    rescue Exception => error
      puts(error.message)
    end
    
    # Check parameters
    options[:applicationNames].each { |applicationName|
      if configurationFile.applicationNames.index(applicationName).nil?
        puts('Warning: The application ' + applicationName + ' has not been defined in the configuration file. Ignored')
      end
    }
    options[:storeNames].each { |storeName|
     if configurationFile.storeNames.index(storeName).nil?
        puts('Warning: The store ' + storeName + ' has not been defined in the configuration file. Ignored')
      end
    }
    options[:identityNames].each { |identityName|
      if configurationFile.identityNames.index(identityName).nil?
        puts('Warning: The identity ' + identityName + ' has not been defined in the configuration file. Ignored')
      end
    }
    
    # Collect all deployment configurations which match the input arguments
    deploymentInfos = []
    configurationFile.applications.each { |application|
      applicationNames = options[:applicationNames]
      if ! applicationNames.nil? && applicationNames.index(application.name).nil?
        next
      end
      
      application.targets.each { |target|
        storeNames = options[:storeNames]
        if ! storeNames.nil? && storeNames.index(target.storeName).nil?
          next
        end

        identityNames = options[:identityNames]
        if ! identityNames.nil? && identityNames.index(target.identityName).nil?
          next
        end
        
        deploymentInfos << DeploymentInfo.new(application.name, target.storeName, target.identityName)
      }
    }
    
    puts deploymentInfos
  end
end