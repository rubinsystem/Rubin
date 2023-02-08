class Instance
  def initialize
    
	
	
	
	##check fileio binding for ones marked public
    
  end
  
  def get_local_ids
    i=Dir.entries(SYSTEM.datadir+"/sys/instance")
	if i.length>0
	  l=[];fl=[]
      i.each do |f|
	    if f.to_s.downcase[-4..-1]==".dat" and f.to_s[0..-5].delete("0123456789").length==0
	      l<<f[0..-5]
	    end
	  end
	  if l.length>0
	    l.each do |ll|
	      f=File.read(SYSTEM.datadir+"/sys/instance/"+ll.to_s+".dat")
		  str=Time.stamp(f)
		  sec=Time.now-str
		  if sec.to_i<30
		    fl<<ll
		  end
	    end
		return fl
	  else; return []
	  end
	else; return []
	end
  end
  
  
  def id ; return INSTANCE ; end
  
  
  def pop
    SYSTEM.host.launch_new(SYSTEM.homedir+"/launch.rb")
  end
  
  
  
  

  
  
  
  class Group_Member_Host
    
  end

  class Group_Member
    
  end  
  
  
end