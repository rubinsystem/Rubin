
puts "Measuring install directory, please wait..."

st=Time.now
map = Dir.map(SYSTEM.homedir)

rb_files=[]
log_files=[]
cfg_files=[]

total_size=0
rb_file_size=0
rb_file_lines=0
log_file_size=0
cfg_file_size=0

map[0].each do |file|
  if file.to_s.downcase[-3..-1] == ".rb"
    rb_files << file
	f=File.open(file,"r"); cont= f.read
	  rb_file_lines += cont.split("\n").length
	  rb_file_size += cont.split("").length
	  total_size += cont.split("").length
	f.close
  elsif file.to_s.downcase[-4..-1] == ".log"
    log_files << file
	f=File.open(file,"r"); cont = f.read
	  log_file_size += cont.split("").length
	f.close
	total_size += cont.split("").length
  elsif file.to_s.downcase[-4..-1] == ".cfg"
    cfg_files << file
	f=File.open(file,"r");  cont = f.read
	  cfg_file_size += cont.split("").length
	f.close
	total_size += cont.split("").length
  else
    s = File.size(file)
	total_size += s.to_i
  end
end


## measure appdir size
## measure classdir size
## measure datadir size
## measure sys dir size



puts "#############################################################"
puts "## Installation Info"
puts "#############################################################"
puts "Rubin:               "+VERSION.to_s
puts "Host:                 ----"
puts "Location:            "+SYSTEM.homedir.to_s
puts "Fingerprint:         "+INSTALLATION_HEADER[5].to_s
puts "Install date:        "+INSTALLATION_HEADER[3].to_s
puts ""
puts "Install Size:        "+total_size.to_i.commas
puts "Files:               "+map[0].length.to_s
puts "Directories:         "+map[1].length.to_s
puts "Ruby Files:          "+rb_files.length.to_s
puts "Total Lines of code: "+rb_file_lines.to_s
puts ""
puts "Config Files:        "+cfg_files.length.to_s
puts "Config size:         "+cfg_file_size.to_s
puts "Log files:           "+log_files.length.to_s
puts "Log size:            "+log_file_size.to_s
puts ""
puts "##############################################################"
puts ""
