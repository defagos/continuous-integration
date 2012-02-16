require 'deploy_ipa/application'
require 'deploy_ipa/deployment_info'
require 'deploy_ipa/configuration_file'
require 'optparse'

class DeployIpa
  # Entry point
  def self.run
    options = DeployIpa.parse_options
    if options.nil?
      return
    end
    
    configuration_file_name = options[:configuration_file_name]
    configuration_file = DeployIpa.load_configuration_file(configuration_file_name)
    if configuration_file.nil?
      return
    end
    
    if ! DeployIpa.check_consistency(options, configuration_file)
      puts('[WARN] Inconsistencies dectected in configuration file ' + configuration_file_name)
    end
    
    deployment_infos = DeployIpa.collect_deployment_infos(options, configuration_file)
    puts deployment_infos
  end
  
  # Parse the command line options. Return a Hash containing the options which have been extracted, nil on failure
  def self.parse_options
    options = {}
    
    # Setup command line parser
    option_parser = OptionParser.new { |parser|
      parser.banner = 'Usage: deploy_ipa [options] configuration_file.yaml'
      parser.version = Gem.loaded_specs['deploy_ipa'].version.to_s
      
      # Application list
      parser.on('-a', '--applications LIST', Array, 'A comma-separated list of the applications to deploy (all if omitted)') { |application_names|
        options[:application_names] = application_names
      }
      
      # Identity list
      parser.on('-i', '--identities LIST', Array, 'A comma-separated list of the identities to deploy applications for (all if omitted)') { |identity_names|
        options[:identity_names] = identity_names
      }
      
      # Store list
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
      puts('[ERROR] Missing YAML configuration file argument')
      success = false
    elsif ARGV.count > 1
      puts('[ERROR] Too many arguments')
      success = false
    end
    
    # Print help if the command line is incorrect
    if ! success
      puts
      puts(option_parser.help)
      return nil
    end
    
    options[:configuration_file_name] = ARGV[0]
    return options
  end
  
  # Load, parse and return the configuration file given as parameter. Return nil on failure
  def self.load_configuration_file(configuration_file_name)
    begin
      configuration_file = ConfigurationFile.new(configuration_file_name)
    rescue Exception => error
      puts(error.message)
      return nil
    end
    
    return configuration_file
  end
  
  # Check consistency between an options Hash and a configuration file. Return true iff no consistencies have been found
  def self.check_consistency(options, configuration_file)
    consistent = true
    
    # Warn about parameter inconsistencies
    options[:application_names].each { |application_name|
      if configuration_file.application_names.index(application_name).nil?
        puts('[WARN] The application ' + application_name + ' has not been defined in the configuration file. Ignored')
        consistent = false
      end
    }
    options[:store_names].each { |store_name|
     if configuration_file.store_names.index(store_name).nil?
        puts('[WARN] The store ' + store_name + ' has not been defined in the configuration file. Ignored')
        consistent = false
      end
    }
    options[:identity_names].each { |identity_name|
      if configuration_file.identity_names.index(identity_name).nil?
        puts('[WARN] The identity ' + identity_name + ' has not been defined in the configuration file. Ignored')
        consistent = false
      end
    }
    
    return consistent
  end
  
  # Return all deployment configurations matching an options Hash, given a configuration file
  def self.collect_deployment_infos(options, configuration_file)
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
    
    return deployment_infos
  end
end