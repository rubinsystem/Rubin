#craigbot.rb

require 'open-uri'
require 'net/http'

class CraigBot
  def initialize
    @threads=[]  ## main threads maybe
	
	@tasks=[]   ## we have need for a thread pool
  end
  def post_initialize
    
	@parser=Parser.new()
    
	@default_config=[]
	@config=@default_config
	
	@appdir=SYSTEM.appdir+"/craigbot"
    
    
	
	
  end
  
  def startup
    cfg=[]
    Dir.entries(@appdir)[2..-1].each do |f|
	  if f.to_s.downcase[0..5] == "config"
	    cfg << @appdir+"/"+f.to_s
	  end
	end
	if cfg.length == 0 ;  return 0 ; end
	cfg.each do |f|
	  self.launch_task(f)
	end
    return cfg.length
  end
   
  
  def launch_task(cfg)
  
  
  end
  
  
  
  
  
  def parser;  return @parser;  end
  
end




class Parser
  def initialize
  end
  
  
  def get_html(url)
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













########################################################################################################
########################################################################################################
####
#### END
####
########################################################################################################
########################################################################################################


@app=CraigBot.new()
@app.post_initialize

@threads=[]  #this is already done before rubin evals this script but we will do it again to be sure.
(@app.instance_variable_get("@threads")).each do |iv|
  @threads << iv
end

$craigbot=@app

## return "self"