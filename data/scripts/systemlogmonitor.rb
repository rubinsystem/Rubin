#file monitor

install_dir=Dir.getwd.to_s.downcase.split("/rubin/")[0]+"/rubin"
p=install_dir+"/system/rubin.rb"


begin
eval(File.read(p).split("\n")[0])
finger_print=INSTALLATION_HEADER[-1].to_s
path=install_dir+"/data/logs/systemlog.log"
eval(s="`TITLE "+install_dir.to_s+" "+ENV['COMPUTERNAME'].to_s+" "+finger_print+"`")
rescue;`TITLE Rubin system log`
end

#until File.exist?(path) 
#  print "File path:";path=gets.chomp.to_s;  if File.exist?(path);break;end
#end
lscr=""
loop do
  begin
	scr=File.read(path)
    if scr!=lscr
      system("CLS");puts scr;lscr=scr
	end
  rescue
  end
  sleep 1.0
end