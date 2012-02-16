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
    
    ARGV.each { |arg|
      puts arg
    }
  end
end