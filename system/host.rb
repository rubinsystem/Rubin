class Host_Manager
  def initialize
    @host="Windows_NT"
    @auto_start_dir=ENV["HOMEDRIVE"]+"/ProgramData/Microsoft/Windows/Start Menu/Programs/StartUp"
  end
  
  def request(cmd);  return system(cmd.to_s);  end
  
  def call(cmd);  self.instance_eval("`"+cmd.to_s+"`");  return nil;  end
  
  def launch(path) ## run file in current session
    if File.file?(path)
	  begin
	    Dir.chdir(path.to_s.split("/")[0..-2].join("/"))
	    n=path.to_s.split("/")[-1]
		system(n.to_s)
		return true
	  rescue; return false
	  end
	else;return false
	end
  end
  
  def launch_new(path) ## run file in new window
    if File.file?(path)
	  begin
	    cdir=Dir.getwd
	    Dir.chdir(path.to_s.split("/")[0..-2].join("/"))
	    n=path.to_s.split("/")[-1]
		system("start "+n.to_s)
		Dir.chdir(cdir)
		return true
	  rescue; return false
	  end
	else;return false
	end
  end
  
  def get_host_identifier; return ENV["COMPUTERNAME"]+":"+ENV["OS"]+":"+ENV["platformcode"]+":"+ENV["PROCESSOR_ARCHITECTURE"]+":"+ENV["PROCESSOR_IDENTIFIER"]+":"+ENV["PROCESSOR_REVISION"]; end 
  
  ## get a list of drives mounted
  def drives
    mounted=[]
    ["C:/","D:/","E:/","F:/"].each { |d| if File.directory?(d);mounted<<d;end }
	return mounted
  end
  
  ## figure out which drive host is installed on
  def host_drive
    return ENV["HOMEDRIVE"]
  end
  
  
  def procs
    str=`TASKLIST`
	procs=[]
    str.split("\n")[3..-1].each do |line|
	  name=line[0..24].split("  ").join("")
      pid=line[26..33].split("  ").join("")	  
	  session_name=line[35..50].split("  ").join("")
	  session_n=line[52..62].split("  ").join("")
	  mem_usag=line[64..75].split("  ").join("")
	  
	  procs << [name,pid,session_name,session_n,mem_usag]
	end
    return procs
  end
  
  def memory_used
    b=0
	self.procs.each do |p|
	  b += p[-1].delete(" ,K").to_i
	end
    return b.commas+" K"
  end
  
  #def memory_installed
  #end
  
  def name;  return ENV["COMPUTERNAME"];  end
  def user;  return ENV["USERNAME"];  end
  
end