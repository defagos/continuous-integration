class Store
  attr_accessor :name
  attr_accessor :url
  
  def initialize(data)
    @name = data['name']
    @url = data['url']
  end
end