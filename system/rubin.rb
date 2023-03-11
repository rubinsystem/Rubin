INSTALLATION_HEADER=["installed", "e:/rubin", "1.0.016", "2023.3.10", "thoma", "D94JG8EH4"]
##First line will always be the install headder

## requires are now handeled by config loader.

puts "Checking system...";BOOT_INIT_TIME=Time.now
boot_log=[]

##check workdir
if Dir.getwd.to_s.downcase!=INSTALLATION_HEADER[1].to_s.downcase
  boot_log << "Workdir is not install dir: "+INSTALLATION_HEADER[1].to_s 
  if File.exist?(INSTALLATION_HEADER[1])
    ##external launch, chdir to install
	Dir.chdir(INSTALLATION_HEADER)
	
	$homedir=Dir.getwd	
  else
    ## the entire install directory has been unexpectedly moved 
	if File.file?(Dir.getwd+"/system/rubin.rb")
	  ##we have located the system core and we can update the installation header
	  ##to this new install directory location.
	    new_homedir = Dir.getwd.downcase.split("/rubin")[0]+"/rubin"
        path=new_homedir+"/system/rubin.rb"
        f=File.open(path,"r");data=f.read;f.close
        header=data.split("\n")[0]
        header=header.split("=")[-1]
        header = self.instance_eval(header)
        header[1]=new_homedir
        header="INSTALLATION_HEADER="+header.to_s
        ndata=header.to_s+"\n"+data.split("\n")[1..-1].join("\n")
        f=File.open(path,"w"); f.write(ndata);  f.close
        Dir.chdir(new_homedir)
		$homedir=new_homedir
		##now we gotta restart
		puts "System Install dir was recently moved and info had to be updated before startup."
		puts "Restarting in 3 seconds."
		sleep 3.0
		system("start launch.rb")
		sleep 0.2
		exit
	else
	  puts "BOOT CANNOT CONTINUE, INSTALLATION NOT FOUND";  sleep 3.0;  raise "BOOT FAILED"#exit
	end
  end  
else;$homedir=Dir.getwd
end

if File.writable?($homedir)!= true
  msg=Time.now.to_s+" : ERROR : CRITICAL : Installation directory is not writable per host!"
  boot_log << msg
  puts boot_log.join("\n")
  ##try to run anyways  ## do something about this
end

## either remove or revise this, we could add a revocery checker right after here
## make a temporary log to help if we end up needing revocery.
f=File.open($homedir+"/bootlog.log","w");f.write("\n"+Time.now.to_s+" : Boot initiated.\n"+boot_log.join("\n"));f.close
  
## Ensure system file exists.
if File.exist?(INSTALLATION_HEADER[1]+"/system/rubin.rb")==false
  msg=Time.now.to_s+" : ERROR : CRITICAL : system file can not be located!"
  f=File.open($homedir+"/bootlog.log","a");f.write(msg);f.close
  exit  ## ABORT BOOT installation not found
end

## Boot criteria met, proceed
msg=Time.now.to_s+" : BOOT SUCCESS."
f=File.open($homedir+"/bootlog.log","a");f.write(msg+"\n");f.close
puts "Initializing..."

## Startup
BOOTTIME=Time.now                     ##
MAIN=self                             ##Somewhat global reference to this context.
INSTANCE=rand(100000)

$sysdir=$homedir+"/system"              ## Rubin system code.
$appdir = $homedir+"/app"               ## App installation files.
$classdir=$homedir+"/class"             ## Classes loaded with ruby, for redefinitions and adding features.
$datadir=$homedir+"/data"               ## General data directory.
$appdatadir = $homedir+"/data/appdata"  ## Apps store data here.
$cfgdir= $homedir+"/data/config"        ## General config directory.
$logdir = $homedir+"/data/logs"         ## General log directory.
$userdir = $homedir+"/data/user"        ##
$bindir=$homedir+"/bin"                 ## For host executable files like interpreters and random exes.


class RubinSystem
  
  VERSION=INSTALLATION_HEADER[2].to_s   ## LAST VERSION UPGRADE 8-12-2022
    
  def initialize

  end
  def startup
	if defined?(POST_INITIALIZATION);  return "false";  end
	
    @homedir=$homedir
    @sysdir=@homedir+"/system" 
    @appdir = @homedir+"/app"   
    @classdir=@homedir+"/class"   
    @datadir=@homedir+"/data"   
    @appdatadir = @homedir+"/data/appdata"
    @cfgdir= @homedir+"/data/config"            
    @logdir = @homedir+"/data/logs"         
    @userdir = @homedir+"/data/user"       
    @bindir=@homedir+"/bin"             

    @daemond=nil              ## reserved for main system threadpool
    @definitions=[]
    @apps=[]                  ## list of app objs and threads loaded   
    @components=[]		
    @loaded_files=[]          ## list of every file loaded since runtime.
	@loaded_apps=[]           ## list of app loads on system  ##revise these too THIS IS SHIT CODE RIGHT HERE
    @loaded_classes=[]
    @app=nil;@threads=[];     ## reserved for system to launch apps 
	
    @shell=nil
	
	## enforce file system
	["/app","/class","/data","/shortcuts","/data/appdata","/data/config","/data/logs","/data/user","/data/definitions","/data/fileio","/data/backups"].each do |f|
	  unless File.exist?(@homedir+f)
	    Dir.mkdir(@homedir+f)
	    begin self.errorlog("SYSTEM ERROR: Missing directory repaired: "+@homedir+"/"+f.to_s)
		rescue
		end
	  end
    end
	
    ##Move boot log into major boot log
    if File.exist?(@homedir+"/bootlog.log")
	  f=File.open(@homedir+"/bootlog.log","r");log=f.read;f.close
	  f=File.open(@logdir+"/bootlog.log","a");f.write(log);f.close
	  File.delete(@homedir+"/bootlog.log")
	else;self.errorlog("Boot log was missing for this boot.")
	end

    	
	## setup config data
	@config_names=["LoadClasses","AutoStartApps","Required",
    "SystemShellAutoStart","DebugMode","DaemondDelay","ShowLogWrites",
    "CtrlNetdir","LoadDefinition","EvaluateFileIO","EvaluateFileIOPrint","RubyGems","AutoScripts"]
	
	@config_descriptions=["",
	                      "",
						  "",
						  "",
						  "",
						  ""]
	
	@default_config=[true,[],["bundler/inline","open-uri","net/http"],true,true,10,false,"",true,false,false,[],[]]
    @config=@default_config
	@loaded_config=""
	
	##check for preconfig.cfg first then config.cfg if it doesnt exist, preconfig can be stacked by adding a number to its name.
	puts "Loading config data..."

	##check for altconfig first, then if none check for preconfig, if none load default config.
	if File.file?(@cfgdir+"/altconfig.cfg")
	  altconfig=@cfgdir+"/altconfig.cfg"
	  f=File.open(altconfig,"r");  altconfig=@cfgdir+"/"+f.read;  f.close
      if File.file?(altconfig)
	    v=self.load_config(altconfig);  @loaded_config = altconfig
        str = "Loaded alternate config: "+altconfig.to_s
		self.writelog(str)
		puts str.to_s
	  else
	    str = "Altconfig could not be found."
		self.errorlog(str)
		puts str.to_s
	  end  
	else ## no altconfig  
	  ##check for preconfig
	  f=Dir.entries(@cfgdir)[2..-1]
      if f.length>0
	    pf=[]
	    f.each do |ff|
	      if ff.to_s.downcase[0..8]=="preconfig" and ff.to_s.downcase[-4..-1]==".cfg"
            pf<<ff
	      end
	    end  
	    if pf.length>0
	      pf=pf.sort
          preconfig=@cfgdir+"/"+pf[0].to_s
		  v=self.load_config(preconfig);  @loaded_config = preconfig
		  n=preconfig.to_s.split("/")[-1]
		  str = "Loaded preconfig: "+n.to_s
		  self.writelog(str)
		  puts str
	    else  ## no preconfig, try to load defualt config
		  if File.file?(@cfgdir+"/config.cfg")
		    v=self.load_config;  @loaded_config = "config.cfg"
			str = "Loaded default config."
			self.writelog(str)
			puts str
		  else  ##config missing, repair and boot with ini defualt config
		    self.save_config ; @loaded_config = "config.cfg"
			str = "Config data was missing or corrupted and had to be restored to default."
			puts str.to_s
		  end
		end
	  else  ##cfgdir is empty
	    self.save_config ;  @loaded_config = "config.cfg"
		str = "Config data was missing or corrupted and had to be restored to default."
	    puts str.to_s
	  end
	end

    ##require files
    
	if @config[2].is_a?(Array)
	  begin
	    @config[2].each do |f|
		  require  f.to_s ; @loaded_files<<f
		  self.writelog("aquired required file: "+f.to_s)
		end
	    if @loaded_files.length > 0
		  if @loaded_files.length>9;  s = @loaded_files.length.to_s+" ";  else;  s = "";  end
		  puts s+"Required files were loaded: "+@loaded_files.join(", ")
		end
      rescue => e
	    self.errorlog("Required file produced this exception:  "+ e.to_s+"\n"+e.backtrace.join("\n")+"\n")
	  end
	elsif @config.to_s=="false"
	else ## config is invalid type
	  self.writelog("Config 2 Requied contains invalid data. It will be repaired.")
	  ##we could save config if its default, we dont want to do that if its pre or alt so do nothing for now
	end

	##load/install rubygems
	if @config[11].length>0
	  puts "Loading Ruby Gems..."
	  required=@config[11]
	  gems=`gem list`;gems=gems.split("\n")
	  gemfiles=[];gems.each {|g| gemfiles<<g.split(" (")[0]}
      required.each do |r|
	    if gemfiles.include?(r)==false
          self.writelog("Attempting to install rubygem: "+r)		
		  puts "Ruby gem is being installed: "+r+" ..."
		  begin
		    gemfile do
              source 'https://rubygems.org'
              gem r.to_s
            end
		    require r.to_s ; @loaded_files << r
		  rescue;msg="Ruby gem could not be installed: "
		    self.errorlog(msg);
		    puts msg
          end
		else;require r.to_s ;  @loaded_files << r
		end
	  end
	end  
	      
	##load definition/s if configured
    if @config[8].to_s=="true" and File.file?(@homedir+"/system/definitions.rb") == true
	  begin
		SYSTEM.instance_eval(File.read(@homedir+"/system/definitions.rb"))
		@definitions<<"definitions.rb" ; @loaded_files<<"definitions.rb"
		puts "Applied definition: definitions.rb"
	  rescue => e
	    msg="Definitions.rb produced an excption.\n"+e.to_s+"\n"+e.backtrace[0..5].join("\n")
		self.errorlog(msg)
		puts msg.to_s
	  end 
	  
	elsif @config[8].length>0
	  puts "Loading "+@config[8].length.to_s+" definitions..."
	  @config[8].each do |file|
	    begin
	      SYSTEM.instance_eval(File.read(@datadir+"/definitions/"+file.to_s));  @loaded_files << file
		  @definitions<<file.to_s
		  puts "Applied definition: "+file.to_s
	    rescue => e
	      msg="Definitions.rb produced an excption.\n"+e.to_s+"\n"+e.backtrace[0..5].join("\n")
          self.errorlog(msg)
		  puts msg.to_s
	    end
	  end
	end


	##Load class files if configured to.
    if @config[0]==true
	  v=self.load_classes
	  if v!=0;puts "Loaded "+v.to_s+" classes."
	  else;puts "No classes were found."
	  end
	end
	
	
	## execute system startup procedures(auto start apps and config changes/settings)	
	@shell=SystemShell.new
	
	##load components
	
	preconstants=self.constants
	
	@real_components=[]
	@components=[]
	c=Dir.entries(@sysdir)[2..-1]
	if c.length>3
	  puts "Loading components: " + (c.length-3).to_s
	  self.writelog("Loading system components: "+c.to_s)
	  c.each {|c| unless c.to_s.downcase=="rubin.rb" or c.to_s.downcase=="daemond.rb" or c.to_s.downcase=="definitions.rb";@components<<c;end}
	  if @components.length>0
	    @components.each do |c|
	      begin;load @sysdir+"/"+c
		  rescue => e ; puts e.to_s
		    self.writelog("Exception loading system component: "+c.to_s)
	      end
	    end
	  end
	end
	
	postconstants=self.constants
    preconstants.each { |c| postconstants.delete(c) }
    preivs=self.instance_variables
	postconstants.each { |c|
	  ivn="@"+c.downcase.to_s
	  begin
        self.writelog("Initializing component: "+c.to_s)
	    self.instance_eval(ivn.to_s+"="+c.to_s+".new()")
	  rescue => e
	    self.errorlog("Component initialization failed: "+c.to_s+e.to_s+"\n"+e.backtrace.join("\n"))
	  end
	}
	postivs=self.instance_variables
	preivs.each { |iv| postivs.delete(iv) }
    @components=postivs
	
	@components.each do |c|
	  self.instance_eval("@real_components << "+c.to_s)
	end

	@real_components.each do |c|
	  if c.methods.include?(:post_initialization)
	    c.post_initialization
	  end
	end
	
	

	self.writelog("Initialization finished.")

	puts "Rubin is starting up."
  end

  def components;return @components;  end
  
  def dirs *args
    if args.length==1 and args[0].is_a?(String)
	  dirname=args[0]
      if dirname.to_s.downcase=="homedir";return @homedir
      elsif dirname.to_s.downcase=="sysdir";return @sysdir
      elsif dirname.to_s.downcase=="appdir";return @appdir
      elsif dirname.to_s.downcase=="classdir";return @classdir
      elsif dirname.to_s.downcase=="datadir";return @datadir
      elsif dirname.to_s.downcase=="logdir";return @logdir
      elsif dirname.to_s.downcase=="cfgdir";return @cfgdir
      elsif dirname.to_s.downcase=="appdatadir";return @appdatadir
      else;return false
	  end
	else;return ["homedir","sysdir","appdir","classdir","datadir","logdir","cfgdir","appdatadir"]
	end
  end  
  def homedir;return @homedir;  end
  def sysdir;return @sysdir;  end
  def datadir;return @datadir;  end
  def appdir;return @appdir;  end
  def classdir; return @classdir;  end
  def appdatadir;return @appdatadir;  end
  def logdir;return @logdir;  end
  def cfgdir;return @cfgdir;  end  
  
  ## Define method links to standard system components, the few we know to exist
  
  
  begin
    def install;return @installation_manager;  end
    def ruby; return @ruby_manager;  end
    def network;return @network_manager;  end
    def host;return @host_manager;  end
    def dic;return @dictionary;  end
    def fileio ; return @fileio ; end
    def instance;return @instance;end
    def instance_id; return INSTANCE ; end
    def controller; return @controller;  end
	def apps;  return @app_controller;  end
    alias :con :controller
    alias :net :network
  rescue; self.errorlog("Rubin was unable to define method links to all loaded components.")
  end  
	

  def start_daemond   
    puts "Starting daemond..."
    if defined?(POST_INITIALIZATION);return false;end
    begin;@daemond=SystemDaemond.new
	  self.writelog("System daemond has started.");return true
	rescue => e ; msg="System Daemond produced exception: "+e.to_s+"\n"+e.backtrace.join("\n")
	  self.writelog(msg)
	  raise msg
	end
  end

  def post_initialization
    unless defined?(POST_INITIALIZATION); 
	  if @config[1].length>0 ##we have startup apps to run
	    msg = "Loading "+@config[1].length.to_s+" startup apps."
		self.writelog(msg)
		@config[1].each do |app|
		  puts "Running autostart app: "+app.to_s
		  self.run(app)
		end
	  end
	  self.writelog("System startup successfull.")
 	  puts "Startup complete Rubin is now running!, Started up in "+(Time.now-BOOT_INIT_TIME).to_s[0..3]+" seconds. "+Time.now.to_s
	  
	  if @config[12].length>0
	    @config[12].each do |f|
		  if File.file?(@datadir+"/scripts/"+f.to_s)
		    begin 
			  str=File.read(@datadir+"/scripts/"+f.to_s)
			  begin
			    self.instance_eval(str)
  			    self.writelog("Autoscript loaded: "+f.to_s)
			    puts "Autoscript loaded: "+f.to_s
			  rescue => e ; self.errorlog("Autoscript produced an exception: "+ e.to_s)
			  end
			rescue ##unable to read autoscript
			end
		  end
		end
	  
	  end
	  
	  ############################	  
	  if @config[3].to_s.downcase=="true"
	    self.writelog("Starting system shell.")
	    if defined?(NOSHELL)==nil
		  puts "Starting system shell."
		  self.shell.start(self)
		end
	  end	  
    end
  end
  
  def cls;  SYSTEM.shell.cls;  end

  def shutdown *args
    proceed=false
	if args[0].to_s[0]=="F"
      proceed=true
    else
	  puts "\nAre you sure you want to shutdown Rubin? Y/N"
	  inp=gets.chomp[0].downcase
	  if inp=="y";proceed=true;end
	end
	if proceed
	  self.writelog("System Shutting down.")
	  
	  self.save_config
	  self.save_cache
	  
	  #maybe attempt to call the method shutdown for each class if it exists
	  #@apps.each {|a| a[0].defined?(shutdown) }  ## do apps only have one thread? thius might be an array of threads
	  
	  @apps.each {|a| v = a[-2];  if v.is_a?(Thread);  v.kill ;  end}  ## do apps only have one thread? thius might be an array of threads
	  
	  self.writelog("Stopped apps.")
	  @daemond.kill
	  self.writelog("Stopped system daemond.")
	  begin
	  File.delete(@datadir+"/sys/instance/"+INSTANCE.to_s+".dat")
	  rescue
	  end
	  self.writelog("System is down.")
	  puts "System is ready to shutdown"
	  sleep 5.0
	  exit
	end
  end
  
  def restart *args
    proceed=false
	if args[0].to_s[0]=="F"
      proceed=true
    else
	  puts "\nAre you sure you want to restart Rubin? Y/N"
	  inp=gets.chomp[0].downcase
	  if inp=="y";proceed=true;end
	end
	if proceed==false;  return false;  end
	
	self.save_config
	self.save_cache
	@apps.each {|a| v = a[-2];  if v.is_a?(Thread);  v.kill ;  end}  ## do apps only have one thread? thius might be an array of threads
	self.writelog("Stopped apps.")
	@daemond.kill
	begin;File.delete(@datadir+"/sys/instance/"+INSTANCE.to_s+".dat");  rescue;;  end
	self.writelog("System is down. Prepairing to restart...")
	sleep 1.0
	self.host.launch_new(@homedir+"/launch.rb")
	sleep 0.1
	exit
  end
  
  def save_altconfig *args
    if args.length == 0
      f=File.open(@cfgdir+"/altconfig.cfg","w");  f.write("config.cfg");  f.close
	  return true
	else	  
      f=File.open(@cfgdir+"/altconfig.cfg","w");  f.write(args[0].to_s);  f.close
	  return true
	end
  end
  
  def altconfig?
    if File.file?(@cfgdir+"/altconfig.cfg")
      f=File.open(@cfgdir+"/altconfig.cfg","r");  d=f.read;  f.close
	  d=@cfgdir+"/"+d
	  if File.file?(d);  return true
	  else;  return false
	  end
    else;  return false
	end
  end

  def remove_altconfig
    if self.altconfig?
	  begin;  File.delete(@cfgdir+"/altconfig.cfg");  return true
	  rescue;  self.errorlog("Failed to delete altconfig file.");  return false
	  end
	else;  return false
	end
  end
  
  def delete_altconfig; return self.remove_altconfig;  end

  def writelog *args# ad option to print
	if File.file?(@logdir+"/systemlog.log")==false;f=File.open(@logdir+"/systemlog.log","w");f.close;end
	ts=Time.now.to_s.split(" ")[0..1].join(".").split(":").join(".").split("-").join(".")
	str="\n"+ts+": "+INSTANCE.to_s+": "+args[0].to_s
	f=File.open(@logdir+"/systemlog.log","a");f.write(str);f.close
	if args[1].to_s.downcase=="true" and @config[6].to_s != "true";  puts "\n"+args[0].to_
	elsif @config[6].to_s == "true"
	  puts args[0].to_s
	end
  end

  def errorlog(msg)  
	ts=Time.now.to_s.split(" ")[0..1].join(".").split(":").join(".").split("-").join(".")
	str="\n"+ts+": "+INSTANCE.to_s+": "+msg.to_s
	str2="\n"+ts+": "+INSTANCE.to_s+": An error occured: "+msg.to_s
	f=File.open(@logdir+"/errorlog.log","a");f.write(str.to_s);f.close	
	f=File.open(@logdir+"/systemlog.log","a");f.write(str2.to_s);f.close	
	begin;if @config[4].to_s.downcase=="true";puts "ERROR: "+msg.to_s;end
	rescue;puts "ERROR: "+str.to_s
	end
  end  
 
  def config *args
    if args.length==0
	 cfg=[];@config_names.each {|c| cfg << [c,@config[@config_names.index(c)]]}
	  return cfg
	elsif args[0].is_a?(Integer) and args.length==1
	  return @config[args[0].to_i]
	elsif args[0].is_a?(Integer) and args.length==2
	  @config[args[0]]=args[1]
	  return true
	elsif args[0].is_a?(String) and @config_names.include?(args[0]) and args.length==1
	  return @config[@config_names.index(args[0])]
	elsif args[0].is_a?(String) and @config_names.include?(args[0]) and args.length==2
	  @config[@config_names.index(args[0])]=args[1]
	  return true
	else;return false
	end
  end
  
  def get_config;return @config;end
  
  def shell;return @shell;end
  
  def cache *args
    if args.length==0;return @cache                                      ##get cache    - no args
    elsif args.length==1&&args[0].is_a?(Array);@cache=args[0]            ##set cache    - Array
	elsif args.length==1&&args[0].is_a?(Integer);return @cache[args[0]]   ##get index   - Integer
	elsif args.length==2&&args[0].is_a?(Integer);@cache[args[0]]=args[1] ##set index    - Integer, Object
	end
  end
  
  def def_objectify_cache ## we may choose to store temp objects in the cache and need to turn them into strings, the name of the objext and reconstruction tag
  end
  
  def save_cache
	begin;f=File.write(@datadir+"/cache.dat","w");f.write(@cache.to_s);f.close
	  self.writelog("Saved cache.")
	  return @cache.to_s.length
	rescue;return false
	end
  end
  
  def clear_cache;@cache=[];return nil;end
	
  def restore_cache
	if File.exist?(@datadir+"/cache.dat")
	  f=File.open(@datadir+"/cache.dat","r");c=f.read;f.close
	  begin;@cache=eval(c)
	    self.writelog("Loaded cache.")
		return true
	  rescue
	    f=File.open(@datadir+"/corrupted_cache.dat","w");f.write(c);f.close
	    f=File.open(@datadir+"/cache.dat");f.write("");f.close
		self.errorlog("Error: Load cache failed. Back up was made and cache file was wiped.")
		return false
	  end
	else
	  self.errorlog("Error: Load cache failed, cache file is missing.")
	  return false
	end
  end
	
  def load_config *args ## you can pass a filepath to load config from or leave blank to load default
    file=false
    if args.length==0 and File.file?(@cfgdir+"/config.cfg")
	  file=@cfgdir+"/config.cfg"
    elsif File.file?(args[0].to_s) and args[0].to_s[-4..-1].to_s.downcase==".cfg"
      file=args[0].to_s
    else
      return false
    end
	f=File.open(file.to_s,"r");cfg=f.read;f.close
	begin;cfg=eval(cfg);@config=cfg;@loaded_cfg_file=file.to_s
	  self.writelog("System config was loaded.")
	  return true
	rescue ## CONFIG DATA CORRUPTED	   
	  self.errorlog("System config load failed due to corruption.")
	  return "error" 
    end	
  end
  
  def save_config *args   ## you can pass a name to save config as or blank for default
    if args.length==0
	  f=File.open(@cfgdir+"/config.cfg","w");f.write(@config.to_s);f.close
	  self.writelog("System config saved.")
	  return true
	elsif args[0].to_s.length>0
	  begin
	    f=File.open(@cfgdir+"/"+args[0].to_s+".cfg","w");f.write(@config.to_s);f.close
	    self.writelog("System config saved as '"+args[0].to_s+"'.cfg.")
	    return true
	  rescue
	    return false
	  end
	else
	  return false
	end
  end
   
  def preconfig?
    cfgs=[]
    Dir.entries(@cfgdir)[2..-1].each { |i| if i.to_s.downcase[0..8]=="preconfig";  cfgs << i;  end }
    if cfgs.length == 0 ;  return false
	else;  return cfgs
	end
  end

  def save_preconfig *args   ##give a preconfig number or it will be assigned automatically, this can overwrite existing preconfigs
    if args.length!=0;  i=args[0].to_i
	else
	  cfgs=[]
      Dir.entries(@cfgdir)[2..-1].each { |i| if i.to_s.downcase[0..8]=="preconfig";  cfgs << i;  end }
      i=cfgs.length
    end
	path=@cfgdir+"/preconfig"+i.to_s+".cfg"
	f=File.open(path,"w");  f.write(@config.to_s);  f.close
    return i
  end
    
  def lock_preconfig
    begin;  f=File.open(@cfgdir+"/lock_preconfig.cfg","w");f.write(Time.stamp);f.close
	rescue;  raise "Failed to create '"+@cfgdir.to_s+"/lock_preconfig.cfg'"
	end
	return true
  end
  
  def unlock_preconfig
    begin
	  File.delete(@cfgdir.to_s+"/lock_preconfig.cfg")	
	rescue;  raise "Failed to delete: '"+@cfgdir.to_s+"/lock_preconfig.cfg'"
	end
	return true
  end
  
  def preconfig_locked?;  return File.file?(@cfgdir+"/lock_preconfig.cfg");  end

  def create_preconfig *args      ## config, integer
    if args[0].is_a?(Array)
	  if args[0].length != @config.length
	    raise "Given config array does not match system config array length."
	  end
	else; raise "First arguement must be config array."
	end
	if args.length==1
	  cfgs=[]
      Dir.entries(@cfgdir)[2..-1].each { |i| if i.to_s.downcase[0..8]=="preconfig";  cfgs << i;  end }
      i=cfgs.length
    else
	  if args[1].is_a?(Integer) == false
	    raise "Second arguement is not an integer."
	  else
	    i=args[1].to_i
	  end
	end
	path=@cfgdir+"/preconfig"+i.to_s+".cfg"
	f=File.open(path,"w");  f.write(args[0].to_s);  f.close
    return i
  end

  def repair_config
    self.writelog("System Config data is being repaired.")
    @config=@default_config 
    self.save_config	 
  end
  
  def repair_cache  ## right now it just resets, later maybe corrupt data extractor
    self.writelog("System Cache data is being repaired.")
	@cache=[]
	self.save_cache
  end
  
  def load_classes  ## load the contents of the class dir
    self.writelog("Searching for classes to load.")
    n=Dir.entries(@classdir)[2..-1]
	if n.length>0
	  self.writelog("Classes found: "+(n.length-2).to_s)
 	  @classes=[]
	  Dir.entries(@classdir)[2..-1].each do |i|
        begin;load @classdir+"/"+i; @classes<<i.to_s ; @loaded_files << i
		  self.writelog("Loaded class: "+i)
	    rescue => e
		  self.errorlog("Loading class file failed: "+i+"\n"+e.to_s+"\n"+e.backtrace.join("\n").to_s)
	    end
      end
	  return (n.length)
	else
	  self.writelog("Attempted to load system classes but there were none.")
	  return 0
	end
  end
 
  def apps?  ##returns an array of apps that are runnable
    apps=[]
    i=Dir.entries(@appdir)[2..-1]
    i.each do |p|
      if File.file?(@appdir+"/"+p)and p.split(".")[-1].downcase=="rb"
	    apps << p[0..-4]
	  end
	  if File.exist?(@appdir+"/"+p) and File.exist?(@appdir+"/"+p+"/"+p+".rb")
	   apps << p
	  end
    end
    return apps  
  end

  def scripts?
    scripts=[]
	Dir.entries(SYSTEM.datadir+"/scripts")[2..-1].each do |i|
	  if File.file?(SYSTEM.datadir+"/scripts/"+i.to_s)
	    if i.to_s.include?(".")==false or i.split(".")[-1].downcase=="rb"
		  scripts << i
	    end
	  end
	end
	return scripts
  end


  def runs(scriptname)  ## a way to control loading scripts from with in the system, not much else use since .load already does this
    s=@datadir+"/scripts/"+scriptname.to_s; if s.to_s.downcase[-3..-1]!=".rb"; s=s+".rb";end
    begin;str=File.read(s)
	  begin; self.instance_eval(str)
	  rescue => e; return e
	  end
    rescue; return false
	end
  end

  def run(appname) ## Appname
	#strip file extension if included
	if appname.to_s[-3..-1].to_s.downcase==".rb";appname=appname.to_s[0..-4]
	else;appname=appname.to_s
	end
	##verify app installed
	if apps?.include?(appname)==false;self.errorlog("Attempted to load an invalid app name: "+appname); return "Invalid app name.";end
	##verify app path
    if File.exist?(@appdir+"/"+appname+".rb")
	  path=@appdir+"/"+appname+".rb"
	elsif File.exist?(@appdir+"/"+appname+"/"+appname+".rb")
	  path=@appdir+"/"+appname+"/"+appname+".rb"
    else
	   
	end
	
	##load and evaluate app script
	begin
	
	  self.writelog("Loading app file: "+appname.to_s+".rb")
      f=File.open(path,"r");source=f.read;f.close
	  @threads=[];threads=[];@app=nil;@appshell=false
	  self.eval(source)  ## WTF ARE YOU DOING HERE

	  if @threads.length>0
	    @threads.each {|t| threads << t }
		self.writelog("App: "+appname.to_s+" : has loaded threads: "+threads.length.to_s)
	  end
	  
	  if @app!=nil;appobj=@app#self.writelog("App object loaded: "+appname.to_s)
	  else;appobj=nil 
	  end
	  	  
	  @apps<<[appname,Time.now.to_s,threads,appobj]
	  @loaded_apps<<[appname,Time.now.to_s]
      @threads=[];@app=nil

      self.writelog("App load success: "+appname.to_s)
	 
	  if @appshell.to_s!="false"
	    self.shell.start(@apps[-1][-1])
	  end

	  
    rescue => e ; 
	  self.writelog("App load failed: "+appname.to_s)
	  msg = "App encountered an exception.\n"+e.to_s+"\n"+e.backtrace.join("\n")
	  self.errorlog(msg)
      return msg
	  
    end

  end

  def delete_app(appname)


  end
  
  def export_app(appname)
  
  end
  
  def import_app(filepath)
  
  end
  
  
  def export_classes(name)  ## add if theres a self.rb put it first
    if name.to_s.length==0;name=Time.now.to_s;end
	path=@classdir+"/"+name.to_s+"-definition.rb"
    if Dir.entries(@classdir).length>2
	  classes=Dir.entries(@classdir)[2..-1]
	  files=[]
	  namesep="#5#;#6#;#9#;#9#;#4#"+";#5#;#6#;#7#;#9#;#6#;#4#"
	  filesep="#8#;#3#;#5#;#3#;#1#"+";#8#;#3#;#5#;#3#;#8#;#5#"
	  first=[]
	  classes.each { |c| 
	    if c.to_s.downcase=="self.rb"
		  f=File.open(@classdir+"/"+c,"r");first<<["#"+c,f.read];f.close
		else;f=File.open(@classdir+"/"+c,"r");files<<["#"+c,f.read];f.close 
		end
	  }
	  if first.length >0 ;files.each{|f| first << f};files=first;end
	  joined=[]
	  files.each {|f| joined<< f[0].to_s+namesep+f[1].to_s}
	  files=joined.join(filesep)
      f=File.open(path,"w");f.write(files);f.close
	  return true
	else;return "$classdir is empty?"
    end
  end
  
  #import_classes("E:/rubin/data/definitions/ossy.rb")
  def import_classes(path)
    if File.exist?(path)
	  if Dir.entries(@classdir).length >2 == false
	    f=File.open(path,"r");definition=f.read;f.close
	    namesep="#5#;#6#;#9#;#9#;#4#"+";#5#;#6#;#7#;#9#;#6#;#4#"
	    filesep="#8#;#3#;#5#;#3#;#1#"+";#8#;#3#;#5#;#3#;#8#;#5#"
		joined_files=definition.split(filesep);  files=[]
		joined_files.each {|f| files<<f.split(namesep)}
		files.each {|f|
		  if f.length==0 or f[0].to_s.length == 0;  next;  end
		  path=@classdir+"/"+f[0].to_s[1..-1]
		  ff=File.open(path,"w");ff.write(f[1].to_s);ff.close
		}
	    return true
	  else;return "$classdir is empty?"
	  end
	else;return "Invalid path"
	end
  end
  
  
  def show_config
    str="";  cfg=[];  i=0	
    @config_names.each do |n|
   	  cfg << i.to_s+"  "+n.to_s+"= "+@config[i].to_s
	  i += 1
	end
	str << "Rubin system config: "+@loaded_cfg_file.to_s+"\n\n"
	str << cfg.join("\n").to_s+"\n"
	return str
  end  
  
  ##fix this stupid shit later
  alias :config? :show_config
    
   
  def change_homedir(str)  ##this should check to see if install headder path matches dir we are changing to
    if File.directory?(str)# and File.writable?(str)
      opath=@homedir
	  begin
	  Dir.chdir(str)
	  $homedir=str;@homedir=str
	  $sysdir=$homedir+"/system"; @sysdir=@homedir+"/system" 
      $appdir = $homedir+"/app"; @appdir = @homedir+"/app"   
      $classdir=$homedir+"/class"; @classdir=@homedir+"/class"   
      $datadir=$homedir+"/data";@datadir=@homedir+"/data"   
      $appdatadir = $homedir+"/data/appdata"; @appdatadir = @homedir+"/data/appdata"
      $cfgdir= $homedir+"/data/config"; @cfgdir= @homedir+"/data/config"            
      $logdir = $homedir+"/data/logs"; @logdir = @homedir+"/data/logs"         
      $userdir = $homedir+"/data/user"; @userdir = @homedir+"/data/user"       
      $bindir=$homedir+"/bin"; @bindir=@homedir+"/bin"                
	  rescue;Dir.chdir(opath);return false
	  end
	  return true
	else;return false
	end
  end
  
  
  
  
  
  
  
  
  ##this is actually really confusing and needs a new name, it launches a ruby file in a new window, thats all, shortcut files have .lnk and host component will be dealing with that
  def shortcut(str)
    if str[-3..-1].to_s.downcase==".rb";str=str[0..-4];end
    if File.exist?(@homedir+"/shortcuts/"+str+".rb")
	  odir=Dir.getwd
	  Dir.chdir(@homedir+"/shortcuts")
	  system("start "+str.to_s+".rb")
	  Dir.chdir(odir)
	  return true
	  
	else;return false
	end
  end
  
  def shortcuts?
    Dir.entries(@homedir+"/shortcuts")[2..-1] 
  end
  
  
  
  
  def environment?
     
	names=["Shell","Daemond","Threads","Components","Classes",
	"Definition","Apps Installed","Apps Loaded","Cache File Size"]

    entries=[@shell.class.name.to_s,
	@daemond.class.name.to_s,
	@daemond.thread_pool.length,
	@components,
	@classes,
	@definitions,
	@installed_apps,
	@loaded_apps,
	@cache.to_s.length]
	
	
  end
  alias :env? :environment?
  
  def help *args
    if args.length==0
	  puts "##################################################################"
	  puts "## "
	  puts "## Welcome to the Rubin system"
	  puts "## "
	  puts "## "
	  puts "## "
	  puts "## More information about the instance variables and methods commonly used in SYSTEM and its components can be read about in the system manual file."
	  puts "## "
	  puts "##################################################################"
	elsif args.length==1 and args[0].is_a?(String)
	  found="Object not found in help file."
	  begin
	    data=File.read(@datadir+"/help_info.txt")
	    data=eval(data)
	    if data.length>0
		  data.each do |i|
		    if i[0].to_s.downcase==args[0].to_s.downcase
			  found=i[1].to_s;break
			end
		  end
		end
	  rescue;found="Help file could not be read, it may be corrupted or missing."
	  end
	  return found
	else
	  return "Pass a method name or object for help info about it."
	end
  end
  
  def info?
    puts "##############################"
    puts "  Rubin system version: "+VERSION.to_s
	puts "  Ruby Version:         "+RUBY_VERSION.to_s
	puts "  Rubygems:             "
	puts "  Host:                 "+ENV["OS"].to_s
    puts "  Definitions loaded:   "+@definitions.length.to_s
    puts "  Classes loaded:       "+@classes.length.to_s
    puts "   "
    puts "  Boot instance:        "+INSTANCE.to_s
    puts "  Boot time:            "+BOOTTIME.to_s
	sec=Time.now-BOOTTIME
	uptime=Time.parse_seconds(sec)
    puts "  Uptime:               "+uptime.join(":").to_s
    puts ""
	a=[]
	@apps.each { |aa| a << aa[3].class.to_s }
    puts "  Apps:                 "+@apps.length.to_s + " "+a.to_s
    puts "  Threads:              "+@daemond.thread_pool.length.to_s
	puts "  Components:           "+@components.length.to_s + " " + @components.to_s
    puts "  Debug mode:           "+SYSTEM.config(4).to_s
    puts "  "
    puts "  Install directory:    "+INSTALLATION_HEADER[1].to_s
    puts "  Installation Id:      "+INSTALLATION_HEADER[5].to_s 
	puts "  Installation Date:    "+INSTALLATION_HEADER[3].to_s
    puts "  "
	m=Dir.map(INSTALLATION_HEADER[1].to_s)
    size=0
	m[0].each { |f| size+=File.size(f)}
	
	puts "  Installation size:    "+size.to_i.commas
    puts "  Files:                "+m[0].length.to_s
    puts "  Directories:          "+m[1].length.to_s
    puts "  "
    puts "  Host Identifier:      "+@host_manager.get_host_identifier.to_s
	puts ""
	internet=false
	begin
	  f=URI.open('https://google.com')
	  f.close
	  internet=true
	rescue
	end
	puts "  Internet Access:      "+internet.to_s
	puts ""
	
  end

  
  class SystemDaemond  ##System daemond is where automatic system stuff happens, later we will have different daemond versions and store the code internally

    def initialize
	  unless defined?(@@DAEMOND_RUNNING);@@DAEMOND_RUNNING=true
	  
        thread_pool=[]
	    eval(File.read($sysdir+"/daemond.rb"))  ##this file contains the daemond script
		
		if self.instance_variables.length>0
		  self.instance_variables.each { |iv|
            thread_pool<<self.instance_variable_get(iv.to_s)
		  
		  }
		else## this means the daemond file was empty or corrupted or for some whackey reason didnt contain the daemond script
		end
		
		@running=true
		@thread_pool=thread_pool ##daemond thread and other system threads.
		@grave_pool=[] ## where dead threads go for fun
	  
	  end
	  
	  def thread_pool; return @thread_pool; end
	  
	  def grave_pool; return @grave_pool; end
	  
	  def push_thread(thread)
	    if thread.is_a?(Thread);@thread_pool<<thread;end
	  end
	  
	  def kill
	    if @thread_pool.length>0
		  @thread_pool.each { |t| begin ; t.kill ; rescue ;; end }
	      @thread_pool.each {|t| @grave_pool<<t}
		  @thread_pool=[]
		  @running=false
		  return true
		else;return false
		end
	  end
	  
	  def restart
	    self.kill
		eval(File.read($sysdir+"/daemond.rb"))
		@running=true
		if self.instance_variables.length>0
		  instance_variables.each { |iv|
		  
			i=self.instance_variable_get(iv.to_s) 
		    if i.is_a?(Thread)
		      if i.alive?; @thread_pool << i ; end
		    end
		  }
		else## this means the daemond file was empty or corrupted or for some whackey reason didnt contain the daemond script
		end
		return true
	  end
	  
	end
	
  end
  
  class SystemShell
    def initialize
	  @context=nil
	  @context_history=[]
	  @cid=nil
	  @log=[]
	  if File.exist?($logdir+"/system_shell.log")==false
	    f=File.open($logdir+"/system_shell.log","w");f.write("");f.close
	  end
	  @password_entry_mode=false
    end
    def start *args
	  if args.length==0;context=MAIN;else;context=args[0];end
      @main_loop=true;@cid=0;@context=context
	  while @main_loop   ########################
	    print @context.class.to_s+":"+@cid.to_s+"<< "
	    @input = gets.chomp;res=nil
		@log<<@context.class.to_s+":"+@cid.to_s+"<< "+@input

	    if @input == "exit";@main_loop=false;res="Exiting shell."
	    elsif @input[0..8]=="*context=" and @input.to_s.length>9
	      begin;@context=eval(@input.to_s);@context_history<<@context;res="Evaluation context has been changed."
	      rescue; res = "Unable to change context to: " + @input[8..-1].to_s
		  end
		
		elsif @input.to_s.downcase=="*cls";system("CLS");res=:NO_RESULT
	    else ##input isnt a builtin command
	      begin
	        res = @context.instance_eval(@input)
		  rescue => e
		    res = "Input caused an exception.\n"+e.to_s+"\n"+e.backtrace[0..1].join("\n")
		  end
	    end
	    
		unless res==:NO_RESULT
		  print @context.class.to_s+":"+@cid.to_s+">> "+res.to_s+"\n"
		end
		@log<<@context.class.to_s+":"+@cid.to_s+">> "+res.to_s+"\n"
	    @cid+=1;@password_entry_mode=false
	  end##this is the end of the loop ##########
    end
	
	def log(str)
	  f=File.open($logdir+"/system_shell.log","a");f.write(Time.now.to_s+" : "+str.to_s+"\n");f.close
	end
  
    def stop
      @main_loop=false
    end
	
	def cls;  system("CLS");  return "The screen was cleared.";  end
	
  end
   
end


SYSTEM=RubinSystem.new    ##initialize the class object first
SYSTEM.startup            ##initialize things that need the class object to be initialized first
SYSTEM.start_daemond      ##start system threads
SYSTEM.post_initialization  ##run autostart apps and maybe shell
POST_INITIALIZATION=true    ##create a flag to lcok down the startup methods
##line below might need to be switched on and off in the future
$system=SYSTEM
##;##;##;##;##;##;##;##;##;##;##;##;##;##;##;##;##;##;##;##
##Hidden_Internal_Data=""