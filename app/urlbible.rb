
class Url_Bible
    def initialize
          @appdatadir=SYSTEM.appdatadir
	  @database_location=@appdatadir+"/urlbible"
	  if File.directory?(@database_location) == false;  Dir.mkdir(@database_location);  end
	  
      @spiderque=[]  ##this is a list of url indexes that are to be searched, spider will resolve them by calling the get_raw_index method in this class
    
	  @bank_size=1000
      @bank_index=0
      @bank=[]	  

	  self.load_open_bank
	end
	
	def add_item(item)
	  if item.to_s=="";  return false;  end
	  if self.search(item)!=false;  return false;  end
	  if @bank.length < @bank_size
	  else
		self.save_bank
		self.load_open_bank
	  end
	  @bank << item
	  return [@bank_index,@bank.length-1]
	end
	
	def load_open_bank
	  banks=Dir.entries(@database_location)[2..-1]
	  if banks.length > 0
	    open=nil
	    banks.each do |b|
	      fp=@database_location+"/"+b
		  f=File.open(fp,"r"); size=f.read.split("\n").length
	      if size < @bank_size
		    open = b.split(".")[0];  break
		  end
	    end
		if open==nil
		  ##all banks are full, make a new one
		  i=Dir.entries(@database_location)[2..-1].length
		  f=File.open(@database_location+"/"+i.to_s+".txt","w"); f.close
		  self.load_bank(i)
		else
		  self.load_bank(open)
		end
	  else
	    ##no banks exist, create first bank
	  end
	end
	
	def load_bank *args
      if args.length==0; i=@bank_index
	  else; i=args[0].to_i
	  end
	  @bank_index=i
	  fp=@database_location+"/"+i.to_s+".txt"
	  f=File.open(fp,"r"); @bank=f.read.split("\n");  f.close
	  return true
	end
	
	def save_bank
	  fp=@database_location+"/"+@bank_index.to_s+".txt"
	  data=@bank.join("\n")
	  f=File.open(fp,"w");  f.write(data);  f.close
	  return @bank_index.to_s
	end
	
	def bank;  return @bank;  end

    def banks?;  return Dir.entries(@database_location)[2..-1].length;  end
	
	def index;  return @bank_index;  end
	
    def search(item)
	  if item.to_s=="";  return false;  end
	  ci=@bank_index;  found=false
	  if @bank.include?(item.to_s);return [@bank_index,@bank.index(item)]
	  else
	    banks=Dir.entries(@database_location)[2..-1]
		banks.delete(ci.to_s+".txt")
		banks.each do |b|
		  fp=@database_location+"/"+b.to_s
		  f=File.open(fp,"r"); data=f.read.split("\n"); f.close
		  if data.length>0
		    if data.include?(item); found=[b.to_s.split(".")[0].to_i,data.index(item)];  break
		    end
		  end
		end
	    return found
	  end
	end
	
	##this methods correct function depends on bank sizes never ever changing
	def get_raw_index(item)
	  s=self.search(item)
	  if s != false
	    i=s[0].to_i
        v=i*@bank_size
	    p=s[1]+1
		tv=v+p
	    return tv-1    ##we had to add 1 to addup the index because bank index values start at 0
	  else;  return false
	  end
	end
	

    def delete_item(item)
	
	end
	
	def delete_bank(i)
	
	end
    
	def wipe_bank(i)
	
	end
	
	def bank_size? *args
	  if args.length==0; return @bank.length
	  else
	    size=false
	    fp=@database_location+"/"+args[0].to_s+".txt"
	    f=File.open(fp,"r");  size=f.read.split("\n").length;  f.close
		return size
	  end
	end
	
end
    

@app=Url_Bible.new()

$urlbible=@app