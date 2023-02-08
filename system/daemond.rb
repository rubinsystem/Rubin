##;##;##;##;##
## Daemond is our Rubin systems background workings.
## This file is ran in the context of main>Rubin_System>Daemond
## The Daemond class requires instance variables defined in this file
## to be of the Thread class.
##
##
##

@daemond=Thread.new{loop do
  ##create instance tag by writing the time in a file to show we are running
  begin
  fp=SYSTEM.datadir+"/sys/instance/"+INSTANCE.to_s+".dat"
  f=File.open(fp,"w");f.write(Time.stamp);f.close
  ##scan all instance files and remove any abandoned instances(clicking close with out shutting down or some other abrupt exit)
  i=Dir.entries(SYSTEM.datadir+"/sys/instance")[2..-1]
  if i.length>0
    i.each do |ii|
	  fp=SYSTEM.datadir+"/sys/instance/"+ii
	  str=File.read(fp)
	  if str.length==0
	    File.delete(fp)	
		SYSTEM.writelog("Outdated and corrupted instance file removed. ("+ii.to_s+")")
	  else
	    stamp=Time.stamp(str)
	    sec=Time.now-stamp
	    if sec.to_i>15
	      File.delete(fp)	
		  SYSTEM.writelog("Outdated instance file removed. ("+ii.to_s+" ; "+str.to_s+" )")
	    end
	  end
	end
  end
  rescue;# SYSTEM.errorlog "Instance update thread had a write failure."
  end
  sleep 5
  
  

end}


@system_heartbeat=Thread.new{
  $system_heartbeat=0
  loop do
    
	##most important few things are done here probably
    
    $system_heartbeat+=1
    sleep 1
  end
}











##;##;##;##;##