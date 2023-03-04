require 'bundler/inline'

class Ruby_Manager
  def initialize
  
    @cfgpath=SYSTEM.cfgdir+"/ruby.cfg"
    
	@default_config=[]
	@config=@default_config
    self.load_config


    @rubydir=self.locate_host_ruby
  
  end



  def rubydir;return @rubydir;end

  def load_config
    if File.file?(@cfgpath)
	  begin;d=File.read(@cfgpath);d=eval(d);@config=d
	  rescue;#SYSTEM.errorlog("Ruby Config could not be loaded, it might be corrupted.")
	  end
	else;#SYSTEM.errorlog("Ruby Config was missing, it had be restored.")
	  f=File.open(@cfgpath,"w");f.write(@default_config.to_s);f.close
	end  
  end
  
  def save_config
  
  end

  def insert_based_launcher
    ##copy host rubys irb files and insert a rubin launcher before them so rubin will run before irb
    ##return path to based launcher.
  end

  def locate_host_ruby  ## recent ruby version update seems to have broken this
    drive=Dir.getwd.split("/")[0]+"/"
    located=false
	##check host drive for ruby
	list=Dir.entries(drive)[2..-1]
	list.each do |pf|
	  if File.directory?(drive+pf)
        if pf.to_s.downcase[0..3]=="ruby"
          located = drive+pf
		end
      end	  
	end
	##possibly check elsewhere?
    return located
  end  




end
