#app controller

class App_Controller
  def initialize
  
  end


  def running?;  return SYSTEM.instance_variable_get("@apps").length;  end

  def get
    apps=[]
	if SYSTEM.instance_variable_get("@apps").length>0
	   SYSTEM.instance_variable_get("@apps").each do |a|
	     apps << a[-1]
	   end
	end
	return apps
  end



end