##installer version 1.2 pkg v 0.0.0 no package included

#begin
puts "Welcome to the Rubin installer system version 2.0.7.4"

launch_directory=Dir.getwd
launch_time=Time.now

puts ""
puts "Dir: "+launch_directory.to_s
puts ""
puts "Would you like to install to this location? (Y/N)"

inp=gets.chomp.to_s[0].downcase
if inp=="y"
  install_dir=Dir.getwd.to_s
else
  puts "Enter install directory."
  install_dir=nil
  loop do
    inp=gets.chomp.to_s
	if File.directory?(inp.to_s);  install_dir=inp.to_s;  break
	else; puts "Invalid directory."
    end
  end
end

puts "Confirming, you want to install to dir?  (Y/N) ;  "+install_dir.to_s

inp=gets.chomp.to_s[0].downcase

if inp!="y"; puts "Fine, then stop wasting my time...\nThe program will exist in 3 seconds.";  sleep 3.0;  exit; end
if File.directory?(install_dir+"/Rubin");  puts "Cannot install here, there is already an installation."; sleep 3.0;  exit;  end

#load data

dir=install_dir

f=File.open(launch_directory+"/rubin 1.0 installer.rb","r"); data = f.read ; f.close
	
#decode data
data=data.split(";;;"+";;").join("\n")
	
maindatasep="#1#::#1#::#0#::#0#::#0#"+"::#1#::#1#"
filenamesep="#1#::#1#::#0#::#0#::#0#"+"::#0#::#1#"
filesep="#1#::#1#::#0#::#0#::#0#"+"::#0#::#0#"
index_sep="#1#::#0#::#0#::#0#::#0#"+"::#0#::#1#"
	
data=data.split(maindatasep)[-1]

index_string=data.to_s.split(index_sep)[0].to_s
	
file_data=data.split(index_sep)[-1]
##process files
	
	
file_data=file_data.split(filesep)
	
nfile_data=[]
	
file_data.each do |d|
  p=d.split(filenamesep)[0]
  di=d.split(filenamesep)[1]
  nfile_data<<[p,di]
end
	
file_data=nfile_data
	
#proces index

f = index_string.split("??")[0].split("?")
di = index_string.split("??")[1].split("?")


Dir.mkdir(dir.to_s+"/rubin")

di.each do |p|
  np=dir+"/"+p
  Dir.mkdir(np)
end

# create files
   
file_data.each do |fd|
  p=dir.to_s+"/"+fd[0].to_s
  f=File.open(p,"w");  f.write(fd[1].to_s);  f.close
end

p=dir.to_s+"/rubin/system/rubin.rb"
f=File.open(p,"r");  dat=f.read;  f.close
    
old_header=dat.split("\n")[0].split("INSTALLATION_HEADER=")[-1]
old_header=eval(old_header.to_s)

dat=dat.split("\n")[1..-1].join("\n")

version=old_header[2].to_s ### for now itll be bugged and write the version as the one of the installing party not the packaged, fix later
head=["installed",dir+"/rubin",version,Time.now.to_s,ENV["USER"].to_s,rand(99999999999999).to_s(36)]
str="INSTALLATION_HEADER="+head.to_s

	
ndat=str+"\n"+dat
f=File.open(p,"w");  f.write(ndat);  f.close

puts "INSTALL SUCCESS!!!"
puts "The program will exit in 5 seconds"
sleep 5.0
exit

## INSTALL PACKAGE BELOW ; VERSION 0.0.0
