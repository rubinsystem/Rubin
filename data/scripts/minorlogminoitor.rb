#file monitor

path="E:/Rubin/data/logs/minor.log"
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