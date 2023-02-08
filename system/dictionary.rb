##
## make search load banks in a second slot instead of unloading current bank when searching other banks, then just
## unload the second bank and no more saving the current bank every time you search


class Dictionary
  def initialize *args
    #ensure dictionary has an appdata directory  
    @logpath=SYSTEM.logdir+"/dictionary.log"
    writelog("Dictionary is initializing. "+self.to_s)
	
	@appdatadir=SYSTEM.appdatadir+"/dictionary"
	if File.directory?(@appdatadir)==false;Dir.mkdir(@appdatadir);end
	
	@cfgpath=@appdatadir+"/config.txt"
	@default_config=["99999","0","database"]
	@config=@default_config
	if File.file?(@cfgpath)==false; self.save_config ; else;  self.load_config;  end
	
	@defbankdir=@appdatadir+"/"+@default_config[2].to_s
	if File.dir?(@defbankdir)==false; Dir.mkdir(@defbankdir);  end
	
	
	@bankdir=@appdatadir+"/"+@config[2].to_s
	
	@bank=[]
	@sbank=[]            ## search slot
	@banks=[]
    @index=0
	@bank_load_length=0
	
	if args.length == 0
	  #self.load_dictionary(@config[2].to_s)
	elsif args[0].to_s.length>0
	  self.load_dictionary(args[0].to_s)
	else
	  return false  
	end
	
  end
 
  def load_config
    begin
	  if File.file?(@cfgpath)
	    f=File.open(@cfgpath,"r");  @config=f.read.split("\n")
	    return true
	  else; return false
	  end
	rescue; raise "Load config failed, file not accessible."
	end
  end
  
  def save_config
    begin; f=File.open(@cfgpath,"w");  f.write(@config.join("\n"));  f.close; return true
	rescue; raise "Failed to access cfg file."
	end
  end
 
  def load_dictionary(name)
    if File.directory?(@appdatadir+"/"+name.to_s)
	  @bankdir=@appdatadir+"/"+name.to_s
	  @bank=[]
	  @banks=[]
      @index=0
	  @bank_load_length=0
      self.load_open_bank
    else; return false
	end
  end
  
  def create_dictionary(name)
    if File.dir?(@appdatadir+"/"+name.to_s)==false
	  Dir.mkdir(@appdatadir+"/"+name.to_s)
	  @bankdir=@appdatadir+"/"+name.to_s
	  @bank=[]
	  @banks=[]
      @index=0
	  @bank_load_length=0
      self.load_open_bank
	else; return false
	end
  end
  
  def delete_dictionary(name)
  
  end
  
  def dictionary?; return @bankdir.to_s.split("/")[-1].to_s;  end
 
  def dictionary_size?(name);  return Dir.entries(@appdatadir+"/"+name.to_s)[2..-1].length;  end
  
  def dictionary_total_size?(name)
    bytes=0
    Dir.entries(@appdatadir+"/"+name.to_s)[2..-1].each { |f|
	  begin;s=File.size?(@appdatadir+"/"+name.to_s+"/"+f.to_s);bytes+=s.to_i
	  rescue
	  end
	}
	return bytes
  end
  
  def get_dictionaries
    dics=[]
	Dir.entries(@appdatadir)[2..-1].each { |d| if File.dir?(@appdatadir+"/"+d.to_s);  dics<< d.to_s; end }
	return dics
  end
  
  
  
  def grab_shell
    SYSTEM.shell.start(self)
  end  
   
   def index;return @index;end
   def bank;return @bank;end
 
 
  def load_open_bank
    #get list of banks
    @banks=[]
    Dir.entries(@bankdir)[2..-1].sort.each { |i| @banks<<i.split(".dat")[0].to_i }

    if @banks.length==0  ## no bank data, create empty bank 0
	  f=File.open(@bankdir+"/0.dat","w");f.close
	  @index=0
	  @bank=[]
	  @banks=[0]
	  @bank_load_length=0
	  writelog("No data bank existed, created bank 0 and loaded it.")
	else  ## bank files exist
	
	  if self.bank_size?(@banks[-1])<@config[0].to_i  ## last bank is open
		writelog("Open bank found:"+@index.to_s)
		self.load_bank(@banks[-1])
	  else                                       ## last bank full, create new one
		@banks<<@banks[-1]+1
		@index=@banks[-1]
		f=File.open(@bankdir+"/"+@index.to_s+".dat","w");f.close
		@bank=[]
		@bank_load_length=0
		writelog("Last bank was full, created a new one and loaded it.")
	  end
	  
    end
    return @index
  end
  

    ##so other methods dont have to implement the same code
  def load_bank(index)
    path=@bankdir+"/"+index.to_s+".dat"
    if File.file?(path)
	  @bank=[]
	  File.read(path).split("\n").each do |line|
	    @bank<< eval(line)
	  end
      @index=index.to_i
	  @bank_load_length=@bank.length
	  writelog("Bank "+@index.to_s+" was loaded. Size: "+@bank.length.to_s)
	  return true
	else;return false
    end
  end
  
  
  def save_bank
    bank=[]
    @bank.each {|i| bank<<i.to_s }
	bank=bank.sort
	f=File.open(@bankdir+"/"+@index.to_s+".dat","w");f.write(bank.join("\n"));f.close
	@bank_load_length=@bank.length
	writelog("Bank "+@index.to_s+" was saved. Size: "+@bank.length.to_s)
	return true
  end  
  

  ##make it able to take no arg and apply to current
  def bank_size?(index)
    if index.to_i==@index;return @bank.length
	elsif File.file?(@bankdir+"/"+index.to_s+".dat")
	  l=@bank.length;unloaded=false
	  if l>0 and l!=@bank_load_length
	    writelog("Unloading current bank "+@index.to_s+" for a size check on bank "+index.to_s)
	    save_bank;@bank=[];unloaded=true
	  elsif l>0
	    writelog("Unloading current bank "+@index.to_s+" for a size check on bank "+index.to_s)
	    @bank=[];unloaded=true
	  end
	  size=File.read(@bankdir+"/"+index.to_s+".dat").split("\n").length
	  if unloaded
	    load_bank(@index)
	  end
	  return size
	else;return false
	end
  end
  
  
  ## returns bank number and index in an array if found, false if not
  def search(name)
    writelog("Search operation begun for tag: "+name.to_s+". Searching current bank "+@index.to_s+".")
    found=false
    @bank.each { |i| if i[0].to_s.downcase==name.to_s.downcase;found=[@index,@bank.index(i)];end}
	
	if found == false
	  
      ##unload current bank so we dont have more than one bank in memory at a  time
	  unloaded=false;l=@bank.length
	  if l>0 and l!=@bank_load_length
	    writelog("Unloading current bank "+@index.to_s+" to search other banks.")
	    save_bank;@bank=[];unloaded=true
      elsif l>0
	    @bank=[];unloaded=true
	    writelog("Unloading current bank "+@index.to_s+" to search other banks.")
	  end
	  
	  ##search the banks that were not loaded
	  banks=[]
	  Dir.entries(@bankdir)[2..-1].sort.each { |i| banks<<i.split(".dat")[0].to_i }
      banks.delete(@index)
	  banks.each do |b|
	    writelog("Searching bank "+b.to_s+".")
	    bank=[]
	    File.read(@bankdir+"/"+b.to_s+".dat").split("\n").each { |l| bank<<eval(l)}
	    bank.each {|i| if i[0].to_s.downcase==name.to_s.downcase;found=[b,bank.index(i)];break;end}
	  end
	  
	  ##reload current bank
	  if unloaded;load_bank(@index);end
	  
    end
	writelog("Search operation complete, result for '"+name.to_s+"' "+found.to_s+".")
    return found
  end
  
  ##add a new item to current bank
  def add(name)
    writelog("Attempting to add the item '"+name.to_s+"' to bank "+@index.to_s+".")
    ##check if word already exists in a bank so we dont add duplicates
    search=self.search(name)
	if search==false
	  writelog("Item '"+name.to_s+"' was not found in any banks.")
	  ##check if current bank has room to add the word, create a new bank if not
	  if @bank.length<@config[0].to_i
	    @bank<<[name.to_s]
		writelog("Item '"+name.to_s+"' was added to bank "+@index.to_s+".")
	  else
	    writelog("Current bank "+@index.to_s+" is full, a new bank must be created.")
	    if @bank.length!=@bank_load_length;save_bank;end
	    load_open_bank
	    @bank<<[name.to_s]
		@bank=@bank.sort
		writelog("Item '"+name.to_s+"' was added to newly created bank "+@index.to_s)
	  end
	  return [@index,@bank.length-1]
	else
	  writelog("Item was not added because it aleady exists at "+search.to_s)
	  return false
    end
  end  
  
  
  def writelog(str)
    begin
	
	f=File.open(@logpath,"a");f.write(Time.now.to_s+" : "+str.to_s+"\n");f.close
	if defined?(@config)
	  if @config[1].to_s=="1";puts str.to_s;end
	end
	
	rescue
	
	begin
	
	if File.file?(@logpath)==false;f=File.open(@logpath,"w");f.close;end
	f=File.open(@logpath,"a");f.write(Time.now.to_s+" : "+str.to_s+"\n");f.close
	
	rescue; SYSTEM.errorlog("Dictionry logwrite failed: "+str.to_s)
	end
	
	end
  end  
   
  
  def digest(string)  
    words=[]
	chars="\\\"'`!~@$#%^&*()-_=+[{]}|:;<>?,./\n\t"
	string.to_s.downcase.tr(chars," ").split(" ").each { |s| if s.only_letters?;words<<s;end }
	if words.length>0
	  
	  words=words.to_s.downcase;  words=eval(words)  ## MAKE SURE YOU CAN DOWNCASE SUCH A MASSIVE STRING
	  
      nwords=[]	
	  words.each { |w| unless nwords.include?(w);  nwords << w ; end }
	  
	  words=nwords
	  
	  added=0
	  words.each { |w| if self.add(w) != false;added+=1;end }
	  return added
	    
	else;return 0
	end
  end
  
  
  
  
  def clean_bank  
    @bank.each do |b|
	  pass=true
	  i=@bank.index(b)
	  deleted=0
	
	
	  
	
	  if pass!=true;@bank.delete_at(i);deleted+=1;end
	end
  
  end
  
  
  
  
end

