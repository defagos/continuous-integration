require 'deploy_ipa/application'
require 'deploy_ipa/deployment_info'
require 'deploy_ipa/configuration_file'
require 'optparse'

class DeployIpa
  def self.run
    options = {}
    
    # Setup command line parser
    option_parser = OptionParser.new { |parser|
      parser.banner = 'Usage: deploy_ipa [options] configuration_file.yaml'
      parser.version = Gem.loaded_specs["deploy_ipa"].version.to_s
      
      # Application list
      application_names = []
      parser.on('-a', '--applications LIST', Array, 'A comma-separated list of the applications to deploy (all if omitted)') { |application_names|
        options[:application_names] = application_names
      }
      
      # Identity list
      identity_names = []
      parser.on('-i', '--identities LIST', Array, 'A comma-separated list of the identities to deploy applications for (all if omitted)') { |identity_names|
        options[:identity_names] = identity_names
      }
      
      # Store list
      store_names = []
      parser.on('-s', '--stores LIST', Array, 'A comma-separated list of the stores to deploy applications to (all if omitted)') { |store_names|
        options[:store_names] = store_names
      }
    }
    
    # Parse the command line destructively
    success = true
    begin
      option_parser.parse!(ARGV)
    rescue OptionParser::InvalidOption => invalid_option_error
      puts(invalid_option_error.message)
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
      puts(option_parser.help)
      return
    end
    
    # Load the configuration file
    begin
      configuration_file = ConfigurationFile.new(ARGV[0])
    rescue Exception => error
      puts(error.message)
    end
    
    # Check parameters
    options[:application_names].each { |application_name|
      if configuration_file.application_names.index(application_name).nil?
        puts('Warning: The application ' + application_name + ' has not been defined in the configuration file. Ignored')
      end
    }
    options[:store_names].each { |store_name|
     if configuration_file.store_names.index(store_name).nil?
        puts('Warning: The store ' + store_name + ' has not been defined in the configuration file. Ignored')
      end
    }
    options[:identity_names].each { |identity_name|
      if configuration_file.identity_names.index(identity_name).nil?
        puts('Warning: The identity ' + identity_name + ' has not been defined in the configuration file. Ignored')
      end
    }
    
    # Collect all deployment configurations which match the input arguments
    deployment_infos = []
    configuration_file.applications.each { |application|
      application_names = options[:application_names]
      if ! application_names.nil? && application_names.index(application.name).nil?
        next
      end
      
      application.targets.each { |target|
        store_names = options[:store_names]
        if ! store_names.nil? && store_names.index(target.store_name).nil?
          next
        end

        identity_names = options[:identity_names]
        if ! identity_names.nil? && identity_names.index(target.identity_name).nil?
          next
        end
        
        deployment_infos << DeploymentInfo.new(application.name, target.store_name, target.identity_name)
      }
    }
    
    puts deployment_infos
  end
  
  def self.parse_command_line_arguments
    
  end
end