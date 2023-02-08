d=Dir.getwd.split("/")[0..-3].join("/")

if File.exist?(d+"/data/autofilemonitor.dat")
  path=File.read(d+"/data/autofilemonitor.dat")
  
else;exit
end

system("title "+path.to_s)

lscr=""
loop do
  begin
	scr=File.read(path)
    if scr!=lscr
      system("CLS");puts scr;lscr=scr
	end
  rescue
  end
  sleep 3.0
end
