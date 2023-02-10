class WebSpider
  def initialize
    ##check rubin and bilbo, refuse startup if they cannot be accessed.
    if defined?(SYSTEM).to_s != "constant";  raise "Webspider cannot see the Rubin System, startup cannot proceed.";  end
    if defined?($bilbo).to_s != "global-variable";  raise "Webspider cannot see BilboDatabase, startup cannot proceed.";  end
  
    @appdatadir=SYSTEM.appdatadir+"/webspider"
	if File.directory?(@appdatadir)==false;  Dir.mkdir(@appdatadir);  end	
	
	@cfgdir=SYSTEM.cfgdir+"/webspider.cfg"
	@quefile=@appdatadir+"/que.txt"
	
	
	
	@state="init"
	@running=nil
	@main_thread=nil
	
	@linkque=[]
	
	@urlbible=nil
	
  end

  def post_initialize
    @urlbible=Url_Bible.new
	
	
	
	
  end

  def urlbible;  return @urlbible;  end


  def main_crawl_loop
    if @running;  return false;  end	
	@running = true
    @main_thread=Thread.new{
	  while @running do
	    
		@current_url=@linkque[0];  @linkque.delete_at(0)		
		html=self.get_html(@current_url.to_s)
		if html!=false
		  links=self.get_links(html)
		  if links.length > 0
		  
		  
		  
		  else;  ##no links on this page, its a dead end
		  end
		  
		else;  ## page could not be read
		end
	  end
	}
	return true
  end







  def get_html(url)  ## returns a pages html, returns html for redirects and doesnt follow them
    begin
	  page=URI(url.to_s)
	  html=Net::HTTP.get(page)
	  html = html.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
	  return html.to_s
	rescue;return false
	end
  end
  
  def get_links(html) # returns url links from elements list
    if html.to_s=="";  return [];  end
	elements=URI.extract(html.to_s)
	urls=[]
	elements.each { |e|	
	  if e.to_s.downcase[0..3]=="http" or e.to_s.downcase[0..2]=="www" or e.to_s.downcase[0..4]=="https"
        begin;URI.parse(e.to_s)
		  urls << e.to_s
		rescue
		end
      end
	}
	return urls
  end

  def get_elements(html);  return URI.extract(html.to_s);  end



  class Url_Bible
    def initialize
	  @appdatadir=SYSTEM.appdatadir+"/webspider"
	  @database_location=@appdatadir+"/urlbible"
	  if File.directory?(@database_location) == false;  Dir.mkdir(@database_location);  end
	  
	  @bank_size=3
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










end









@app=WebSpider.new
@app.post_initialize

$spider=@app
