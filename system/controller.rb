##controller 1.0.01 1-22-23 rubin instance-network controller, thomasjslone
# allows rubin to behave like a botnet

class Controller          ## virtual network vis shared windows folders
    
    ## new idea, we do this to track component versions seperate from system versions.
  
  def initialize
    
	@config_names=["Network_Directory","Network_Host","UserPriv"]
	@default_config=["",""]
	@config_data=@default_config
	
	@logpath=SYSTEM.datadir+"/logs/controller.txt"
	
	@cfgpath=SYSTEM.datadir+"/config/controller.cfg"
    if File.file?(@cfgpath) == false;  self.save_config
	else;  self.load_config
	end
    
	@controller_state="initialized"
    @binding=nil
    @network_directory=''   
	@fileio_directory=SYSTEM.datadir+"/fileio"
	@bound=false   
	   
	@dir_cleaner_thread=nil

  end





  def cleaning?;  return @dir_cleaner_thread.alive?;  end

  def post_initialization  ## since we dont do any initializing in this file we dont call this here either, rubin system does after running this file
    @controller_state ="post_initialization"	
	
	if File.directory?(SYSTEM.config(7).to_s)
	  @network_directory=SYSTEM.config(7).to_s
	  self.start_main_binding
	  SYSTEM.writelog("Controller bound to dir:"+@network_directory.to_s)
	elsif SYSTEM.config(7).to_s=="" or SYSTEM.config(7) == nil or SYSTEM.config(7).to_s == "false"
      @network_directory=@fileio_directory
	  SYSTEM.writelog("Controller network directory not set, using fileio dir but not launching control binding.")
	  @controller_state = "inactive"
	else
	  SYSTEM.errorlog "Controller network directory was invalid, you can reconfigure it using SYSTEM.config(7,'path')."	  
	  @controller_state = "failed init"
	end
    return nil
  end
  
  
  def start_main_binding
    if @binding != nil;  return false;  end
	@binding=FileIO_Eval_Binder.new(@network_directory,"eval",true)
    @binding.start
	@bound=true
	if File.file?(@network_directory+"/cleaner.tag") == false  ##if you have problems with files not getting deleted just run the cleaner thread manually for now
	  self.spawn_dir_cleaner  
	else
	  s=File.read(@network_directory+"/cleaner.tag")
	  if s.to_s==""; str=Time.now-100
	  else;  str=Time.stamp(s.to_s)
	  end
	  tn=Time.now-str
	  if tn.to_i>9
	    self.spawn_dir_cleaner
	  end
	end
    @controller_state = "running"
	return true
  end
  
  def stop_main_binding
    @binding.stop;  @binding=nil; @state="stopped"
  end
  
  
  

  def spawn_dir_cleaner
    if @dir_cleaner_thread!=nil;  return false;  end
	
    @cleaning_thread=Thread.new{loop do
	  begin;  f=File.open(@network_directory+"/cleaner.tag","w");  f.write(Time.stamp);  f.close;  rescue; SYSTEM.errorlog "Controller cleaner thread failed to write tag file." ;  end

	  begin
	  e=[]
	  Dir.entries(@network_directory)[2..-1].each { |v| e << @network_directory+"/"+v.to_s }
	  
	  
	  e.each do |ee|
	    if ee.split("/")[-1][0..11]=="fileio_link-"
	      fp = ee
		  begin;  str=File.read(fp)
		  rescue;  SYSTEM.errorlog("Controller dir cleaner thread had a read failure so the loop itteration was skipped.");  next
		  end
		  str2=Time.stamp(str)
		  tn = Time.now
		  sec=tn-str2
		  if sec.to_f>9
		    i=ee.split("/")[-1][12..-5]
			d=ee.split("/")[0..-2].join("/")
		    fp1=d+"/fileio_input"+i.to_s+".txt"
		    fp2=d+"/fileio_output"+i.to_s+".txt"
			begin ; File.delete(ee) ; rescue ;; end
		    begin ; File.delete(fp1) ; rescue ;; end
		    begin ; File.delete(fp2) ; rescue ;; end
			SYSTEM.writelog("Fileio deleted an old link: "+fp.to_s)
		  else
		  end		  
	    end
	  end
	  
	  rescue;  #SYSTEM.errorlog("Controller dir cleaner thread rescued an unknown error.")
	  end
	  sleep 5
    end
	begin;  File.delete(@network_directory+"/cleaner.tag");  rescue; SYSTEM.errorlof "Controller cleaner failed to delete tag after thread died."  ;  end
	}    
    
  end

  
  
  def binding;  return @binding;  end
  
  

  def members?
    e=Dir.entries(@network_directory)[2..-1]
	if e.length == 0 ;  return []
	else
	  l=[]
      e.each do |ee|
	    p = @network_directory + "/" + ee.to_s
	    if ee.include?("fileio_link-")
	      l<<ee.split("-")[-1].split(".")[0]
	    end
	  end
	  return l
    end
  end
  
  def write(inst,str)
    if members?.include?(inst.to_s)
	  fp=@network_directory+"/fileio_input"+inst.to_s+".txt"
	  if File.file?(fp) == true
	    begin;  File.write(fp,str.to_s); return str.to_s.length
		rescue;  raise "Controller failed to write file: "+fp.to_s
		end
	  else;  raise "Controller fed invalid filepath: "+fp.to_s
	  end
	else;  raise "Invalid inst passed."
	end
  end
  
  def read(inst)
    fp=@network_directory+"/fileio_output"+inst.to_s+".txt"
	begin; str=File.read(fp);
	rescue; raise "Controller read failed: "+fp.to_s; str=false
	File.delete(fp)
	end
    return str
  end
  
  def request(inst,str)
    if File.file?(@network_directory+"/fileio_output"+inst.to_s+".txt"); File.delete(@network_directory+"/fileio_output"+inst.to_s+".txt");  end
    if self.write(inst.to_s,str.to_s).is_a?(Integer)
	  c=0
	  res = nil
	  loop do
	    if c>10;  res=nil;  break;  end
		if File.file?(@network_directory+"/fileio_output"+inst.to_s+".txt")
		  res=self.read(inst.to_s)
		  break
		end
		c+=1;  sleep 1
	  end
	  return res
	else;  raise "Request failed because Controller.write raised a message."
    end
  end

  def input(inst)
    if members?.include?(inst.to_s)
	  fp=@network_directory+"/fileio_input"+inst.to_s+".txt"
	  print"\n";  str=gets.chomp
	  if File.file?(fp) == true
	    begin;  File.write(fp,str.to_s); return str.to_s.length
		rescue;  raise "Controller failed to write file: "+fp.to_s
		end
	  else;  raise "Controller fed invalid filepath: "+fp.to_s
	  end
	else;  raise "Invalid inst passed."
	end
  end



  def writelog(str)
    if str.to_s.length <= 0;  return false;  end
	if File.file?(@logdir) == false;  f=File.open(@logdir,"w");  f.close;  end
    ts=Time.now.to_s.split(" ")[0..1].join(".").split(":").join(".").split("-").join(".")
    f=File.open(@cfgpath,"a"); f.write(ts+": "+str.to_s)
	return true
  end

  def save_config
    begin;  File.write(@config_data.to_s)
	rescue;  return false
	end
	return true
  end
  def load_config
    begin;  @config_data=eval(File.read(@cfgpath))
    rescue;  return false
    end
	return true
  end
  
  def state;  return @controller_state;  end

  def log;  return self.binding.log;  end

  def dir;  return self.binding.dir;  end
  
  

  class FileIO_Eval_Binder  ## rename to control binding
    def initialize(dir,mode,log) ## mode: read / eval
	  
      fp=dir.to_s+"/fileio_input"+SYSTEM.instance.id.to_s+".txt"
	  fp2=dir.to_s+"/fileio_output"+SYSTEM.instance.id.to_s+".txt"	 
	  
	  @dir=dir                                           ##bound dir
	  @inpath=fp
	  @outpath=fp2
	  f=File.open(@inpath,"w");  f.close
	  
	  if mode.to_s=="eval";  @eval_allowed=true; @mode="eval"
	  elsif mode.to_s=="read"; @eval_allowed=false; @mode="read"
	  end
	  
	  @eval_idle_delay=1.0
	  @eval_delay=0.1
	  
	  @log=true
	  @private_log=[]

	  @name=rand(100000000000).to_s(36)
	  @admin=false   

      @state='initializing'	  
	  @running=false
	  @thread=nil
	  @tracker_thread=nil

	  @context=SYSTEM   ##make this an init arg
	  @buffer=[]
	  
	  @eval_toggle=nil   ##
	  
	end

    def start
      if @running;  return false;  end
      @running=true; @state="active";  @opid=0
	  
	  if @mode=="eval"
	  
	  @thread=Thread.new{
	    loop do
	      if @running == false;  break;  end
		  @state="active"
		  if File.file?(@inpath) == true
    
	        begin;  str=File.read(@inpath)  ##this should fix our random and rare error (error: no file ; controler.rb 267)
	        rescue; next  ##the file exists but couldnt be read because its already open in another session, just skip the rest of the loop and continue normally.
			end
				
			if str.length > 0
			  begin;File.write(@inpath,"")
			  rescue
			  end
			  @buffer<<@opid.to_s+"<< "+str.to_s
	          if @eval_allowed != true ; sleep @eval_idle_delay;  next ;  end
			  begin
			    @state="evaluating"
			    res=@context.instance_eval(str)  
			  rescue => e
			    res = "EXCEPTION::: " + e.to_s + "\n" + e.backtrace.join("\n")
			  end
			  @state="posting"
			  begin;  File.write(@outpath,res.to_s)
			  rescue
			  end
			  sleep @eval_delay
			  @buffer << @opid.to_s+">> "+res.to_s
			  
			  begin
			  
			  if @log==true
			    s1=SYSTEM.instance.id.to_s+":"+@opid.to_s+":"+Time.stamp
			    s2="<< "+str.to_s
				s3=">> "+res.to_s
				s4=s1+"\n"+s2+"\n"+s3+"\n"
				if File.file?(@dir.to_s+"/log.txt") == false
				  s5=SYSTEM.instance.id.to_s+":"+@opid.to_s+":"+Time.stamp+": Dir log created. ("+@dir.to_s+")"
				  f=File.open(@dir.to_s+"/log.txt","w");  f.write(s5);  f.close
				end
				f=File.open(@dir.to_s+"/log.txt","a");  f.write(s4);  f.close
				@private_log << s4
			  end
			  
			  rescue;  SYSTEM.errorlog "Controller eval log write failed."
			  end
			  
			  @opid += 1
			  @state="idle";  sleep @eval_idle_delay
			else; @state="idle"; sleep @eval_idle_delay
			end
	      else;  @state="idle";  sleep @eval_idle_delay
		  end
		  
	    end
	    @running=false; @state="stopped"
	  }
	  
	  end
	  
	  self.spawn_tracker_thread
      
	  return true
	end

	def spawn_tracker_thread
	  @tracker_thread=Thread.new{
	    loop do
	      if @running==false
		  else
		    id=SYSTEM.instance.id.to_s
            fp=@dir+"/fileio_link-"+id+".txt"
		    f=File.open(fp,"w");  f.write(Time.stamp); f.close 
		  end
	      sleep 5.0
	    end
	  }
	end
	
	
    def stop
	  if @running == true
	    @thread.kill;  @thread=nil
		@tracker_thread.kill; @tracker_thread=nil
		@running=false
		return true
	  else;  return false
	  end
	end


    def lock;  @eval_allowed=false;  end
	def unlock;  @eval_allowed=true;  end
	def mode *args
	  if args.length == 0 ;  return @mode
	  else; @mode = args[0].to_s
	  end
	end
	
    def dir;  return @dir;  end
	
	def log; return @private_log;  end
  
  end
  
  
  
  
end

@controller=nil
def controller;  return @controller;  end
alias :con :controller



  
  
  
  
