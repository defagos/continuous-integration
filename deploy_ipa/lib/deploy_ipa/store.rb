require 'deploy_ipa/configuration_file'

class Store
  attr_accessor :name
  attr_accessor :url
  attr_accessor :contents
  
  def initialize(data, configuration_file)
    @name = data['name']
    @url = data['url']
    @contents = data['contents']
    @configuration_file = configuration_file
  end
end