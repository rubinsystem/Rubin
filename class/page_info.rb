
class Page_Info
  def initialize *args
    if args[0].to_s=="new"
	  @page_url=args[1].to_s
	  @page_index=0
	  @page_url=""
	  @page_host=""
	  @page_size=0
	  @page_encoding=""
	  @page_title=""
	  @page_accessed=[""]
	  @page_links=[""]
	  @page_file_links=[""]
	elsif args[0].to_s=="load"
	  self.setdata(args[1].to_s)
	end
  end
  
  def getdata
    i=@page_index.to_s+"^"+@page_url.to_s+"^"+@page_host.to_s+"^"+@page_size.to_s+"^"+@page_encoding.to_s+"^"+@page_title.to_s
	p=@page_accessed.join(",")
	u=@page_links.join("? ?")
	f=@page_file_links.join("? ?")
	i = i + "^" + p.to_s + "^" + u.to_s + "^" + f.to_s
	return i
  end

  def setdata(i)
    i=i.split("^")
	@page_index=i[0].to_i
	@page_url=i[1].to_s
	@page_host=i[2].to_s
	@page_size=i[3].to_i
	@page_encoding=i[4].to_s
	@page_title=i[5].to_s
	@page_accessed=i[6].to_s.split(",")
	@page_links=i[7].to_s.split("? ?")
	@page_file_links=i[8].to_s.split("? ?")
	return true
  end

  def update_page
    if @active == true ;  return true;  end
    @update_thread=Thread.new{ @active=true
	  
	  
	  ##get html
	  ##get links
	  ##digest dictionary
	  ##extrack emails and phone numbers
	  
	  @active=false
	}
    return nil
  end


  def index;  return @page_index.to_i;  end
  def url;  return @page_url.to_s;  end
  def host;  return @page_host.to_s;  end
  def size;  return @page_size.to_i;  end
  def encoding;  return @page_encoding.to_s;  end
  def title;  return @page_title.to_s;  end
  def accessed;  return @page_accessed;  end
  def links;  return @page_links;  end
  def file_links;  return @page_file_links;  end
  
  
  
  
  
end