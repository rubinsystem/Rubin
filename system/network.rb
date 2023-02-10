#network

class Network_Manager
  def initialize
    @uri=nil	
	
	
  end
  def post_initialize
    @uri=Uri_Class.new

  end
  
  
  
  def uri;  return @uri;  end
  
  
  class Uri_Class
  
  end
end