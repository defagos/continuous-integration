class Application
  attr_accessor :name
  attr_accessor :repositoryURL
  
  def initialize(data)
    @name = data['name']
    @repositoryURL = data['repository_url']
  end
end