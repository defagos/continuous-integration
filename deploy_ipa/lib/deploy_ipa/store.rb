require 'configuration_file'

class Store
  attr_accessor :name
  attr_accessor :url
  attr_accessor :contents
  
  def initialize(data, configurationFile)
    @name = data['name']
    @url = data['url']
    @contents = data['contents']
    @configurationFile = configurationFile
  end
end