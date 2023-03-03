  
class BilboDatabase
  def initialize *args
    @logfilepath=SYSTEM.logdir+"/bilbodatabase.log"
    @appdatadir=SYSTEM.appdatadir+"/bilbodatabase"
    @cfgfilepath=@appdatadir+"/dbconfig.txt"
	@bank_dir=@appdatadir+"/bank"
	@loaded_bank_dir=""
    
	if File.dir?(@appdatadir) == false;  Dir.mkdir(@appdatadir);  end
	if File.dir?(@bank_dir) == false;  Dir.mkdir(@bank_dir);  end
	if File.file?(@logfilepath) == false;  f=File.open(@logfilepath,"w");f.write("");f.close;  end
	
	@bank_size_limit=100000
	
	@default_config=[@bank_size_limit,"default"]
	@config=@default_config
	@config_names=["Database size","default database to load"]
	
	if File.file?(@cfgfilepath) == false
	  @config=@default_config
	  self.save_config
	else
	  self.load_config
	end
	
	## any time we load a new bank or dictionary we refresh these, use self.empty_bank to do it
	@bank=[]
	@loaded_bank=0
		
	if File.dir?(@bank_dir+"/"+args[0].to_s) and args[0].to_s.length > 0
	  self.load_named_bank(args[0].to_s)
	else  ## load default or dont load
	  if File.directory?(@bank_dir+"/default")==false;  Dir.mkdir(@bank_dir+"/default");  end
	  self.load_named_bank("default")
	end	
	return true ## database is up and running
  end
  
  def save_config
    f=File.open(@cfgfilepath,"w"); f.write(@config.join("^?^")); f.close
	return true
  end
  
  def load_config
    begin
	  f=File.open(@cfgfilepath,"r");cfg=f.read.split("^?^");f.close
	  @config=[cfg[0].to_i,cfg[1].to_s]
	  @bank_size_limit=cfg[0].to_i
	  @database_name=cfg[1].to_s
	  return true
	rescue;  return false
	end
  end 
  
  def add_new_page(url)
    if data.to_s=="";return false; end
	if @bank.length<@bank_size_limit.to_i
	else; self.load_open_bank
	end
	page=Page_Info.new("new",url.to_s)
	@bank<<page
	return @bank.length-1
  end
  
  def insert_page(page)
    if page.class.to_s != "Page_Info";  raise "insert_page requires Page_Info object as arguement.";  end
    if @bank.length<@bank_size_limit.to_i
	else;  self.load_open_bank
	end
    @bank << page
    return @bank.length-1
  end
  
  def delete_page(url)
    
  
  
  end
  

  def load_named_bank(name)
    if File.dir?(@bank_dir+"/"+name.to_s)
      @loaded_bank=0
	  @bank=[]
	  @loaded_bank_dir=@bank_dir+"/"+name.to_s
	  self.load_open_bank
    else;  return false
	end
  end

  def create_named_bank(name)
    if File.dir?(@bank_dir+"/"+name.to_s) == false
	  begin
	    @loaded_bank_dir=@bank_dir+"/"+name.to_s
	    Dir.mkdir(@loaded_bank_dir)
	    @loaded_bank=0
		@bank=[]
		self.load_open_bank
		return true
	  rescue; raise "Failed creating bank."
	  end
	else;  return false
	end
  end

  def delete_named_bank(name)
  
  end

  def load_open_bank
    banks=Dir.entries(@loaded_bank_dir)[2..-1]
	if banks.length==0; f=File.open(@loaded_bank_dir+"/0.txt","w"); f.close
	else
      banks.each do |b|
        if self.bank_size(b.to_s.split(".")[0].to_s).to_i < @bank_size_limit
		  self.load_bank(b.to_s.split(".")[0].to_s)
		else
		  if b == banks[-1]
		    ##make a new bank index and load it
		    banks=Dir.entries(@loaded_bank_dir).length-2
            nb=banks+1
            @loaded_bank=nb
	        @bank=[]
	        f=File.open(@loaded_bank_dir+"/"+nb.to_s+".txt","w");f.close
		  end
		end
      end
    end	
  end

  def bank_size(i)
    return File.size(@loaded_bank_dir+"/"+i.to_s+".txt")
  end
	
  def load_bank(i)
    f=File.open(@loaded_bank_dir+"/"+i.to_s+".txt","r");bank=f.read.split("\n")
	@bank=[]
	bank.each { |b| @bank << Page_Info.new(b) }
	return true
  end

  def save_bank
    bank=[]
    @bank.each { |b| bank << b.getdata }
	f=File.open(@loaded_bank_dir+"/"+@loaded_bank.to_s+".txt","w")
	f.write(bank.join("\n"))
	f.close
	return true
  end  
  
  def unload_bank
    @bank=[]
	@loaded_bank=0
	return true
  end
  
  def save_bank_as(i)
    bank=[]
	@bank.each { |b| bank << b.getdata }
    f=File.open(@loaded_bank_dir+"/"+i.to_s+".txt","w");f.write(bank.join("\n"));f.close
	return true
  end

  def empty_bank
    @loaded_bank=0
	@bank=[]
  end


  def bank;  return @bank;  end
  def bank_name;  return @loaded_bank_dir.to_s.split("/")[-1].to_s;  end
  def index;  return @loaded_bank;  end

  def writelog(str)
    t=Time.now.to_s.split(" ")[0..1].join(".").split("-").join(".").split(":").join(".")
    f=File.open(@logfilepath,"a");f.write(t+" : "+str.to_s)
    return nil
  end


##  Web Page Information Object v 1.1
##  depreciated to classdir


end


@app=BilboDatabase.new

$bilbo=@app