#RubinSystem log monitor v 1.3, 2023.3.3
#check if we are in a rubin directory
if Dir.getwd.to_s.downcase.include?("rubin")==false;  raise "Cannot locate the 'Rubin' directory."; end
#locate installation and log file
install_dir=Dir.getwd.to_s.downcase.split("/rubin/")[0]+"/rubin"
path=install_dir+"/system/rubin.rb" 
logpath=install_dir+"/data/logs/systemlog.log"
if File.file?(path) == false;  raise "Cannot locate installation.";  end
if File.file?(logpath) == false;   "Cannot locate system log.";  end
## get install info and set window title
begin
eval(File.read(path).split("\n")[0])
finger_print=INSTALLATION_HEADER[-1].to_s
eval(s="`TITLE "+install_dir.to_s+" "+ENV['COMPUTERNAME'].to_s+" "+finger_print+"`")
rescue;`TITLE Rubin system log`
end
##prepare screen
buffer="";  size=0;    refresh_delay=1.0
system("CLS")
## enter file monitoring loop
loop do
  begin
	s=File.size(logpath)
    if s!=size
	  size=s
	  buffer=File.read(logpath)
      system("CLS")
	  print buffer+"\n"
	end
  rescue
  end
  sleep refresh_delay
end