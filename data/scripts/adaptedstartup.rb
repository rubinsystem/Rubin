#

new_homedir = Dir.getwd.downcase.split("/rubin/")[0]+"/rubin"

puts "New home dir? "+new_homedir.to_s
inp=gets.chomp.downcase
if inp[0]!="y"; exit ;  end

puts "Modifying installation header to include new install directory."
path=new_homedir+"/system/rubin.rb"
f=File.open(path,"r");data=f.read;f.close

header=data.split("\n")[0]
header=header.split("=")[-1]
header = self.instance_eval(header)
header[1]=new_homedir
header="INSTALLATION_HEADER="+header.to_s
ndata=header.to_s+"\n"+data.split("\n")[1..-1].join("\n")

f=File.open(path,"w"); f.write(ndata);  f.close

puts "Changing workdir to install location."

Dir.chdir(new_homedir)

puts "Preparing to launch."

load "launch.rb"