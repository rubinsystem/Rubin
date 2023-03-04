##webspider.rb
##
##  Takes a base link and crawls starting there
##  Can be set with a base que soon, im about to add
##


class WebSpider
  def initialize
    ##check rubin and bilbo, refuse startup if they cannot be accessed.
    if defined?(SYSTEM).to_s != "constant";  raise "Webspider cannot see the Rubin System, startup cannot proceed.";  end
    if defined?($urlbible).to_s != "global-variable";  raise "Webspider cannot see UrlBible, startup cannot proceed.";  end
    if defined?($bilbo).to_s != "global-variable";  raise "Webspider cannot see BilboDatabase, startup cannot proceed.";  end
    
    @appdatadir=SYSTEM.appdatadir+"/webspider"
    if File.directory?(@appdatadir)==false;  Dir.mkdir(@appdatadir);  end	
    
    
    @quefile=@appdatadir+"/que.txt"
	if File.file?(@quefile);  f=File.open(@quefile,"w");f.close;end
    @quepointer=0                             ## we will keep track of how many urls we have loaded by their index
    
    @default_config=[10000] ## que limit, we will wait for url bible to have enough links for us to grab 10000 new urls
    @config=[]
    @cfgfile=SYSTEM.cfgdir+"/webspider.cfg"
	if File.file?(@cfgfile);  f=File.open(@cfgfile,"w");f.close;end
    
	@datafile=@appdatadir+"/webspider.dat"
	
	@crawl_pointer=0
	@crawl_start_time=nil
	@que=[]
    @state="init"
    @running=nil
    @main_thread=nil
    @linkque=[] #* 
    @urlbible=nil
	
  end

  def begin_new_crawl
    
	@crawl_pointer = 0
	@crawl_start_time = Time.stamp
    
  end


  def post_initialize


  
  
    ##load que from link bible and start crawl loop
	
  end

  def


  def main_crawl_loop
    if @running;  return false;  end	
	@running = true
    @main_thread=Thread.new{
	  while @running do
	 
	 
	  end
	}
	return true
  end


  def crawl_step
    
	url = $urlbible.get(@crawl_pointer)
	
	check = $bilbo.search(url)
	
	
	
	@crawl_pointer+=1
	
  end




  def get_html(url) #may return redirects
    begin
	  page=URI(url.to_s)
	  html=Net::HTTP.get(page)
	  html = html.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
	  return html.to_s
	rescue;return false
	end
  end
  
  def get_links(html)
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



  






end









@app=WebSpider.new
@app.post_initialize

$spider=@app
