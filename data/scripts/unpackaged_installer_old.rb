puts "Welcome to the installer, checking your system real quick."

dont_install=false
install_complete=false
if defined?(SYSTEM)
  puts "This is an external rubin installer, you can run it by double clicking on its file"
  puts "in your file explorer or by passing its file path to your ruby interpreter in your"
  puts "host system command console."
  dont_install=true
end




puts "Enter directory to install in or just press enter to install to "+Dir.getwd+"."
input=""
until File.directory?(input)
  input=gets.chomp.to_s
  if input.length==0
    input=Dir.getwd;break
  else
    if File.directory?(input);break	
	else;puts "Input is not a directory."
	end
  end
end
destination=input

begin
  if dont_install;return false;end
  

  if File.writable?(destination)==true
    if File.directory?(destination+"/rubin")==false
      
	  sep="#43#;#77#;#43#;#23#"+";#45#;#65#;#77#;#04#;#75#"
      source=File.read(__FILE__).split(datasep)[-1].to_s

      filenamesep="#4#;#5#;#6#"+";#2#;#2#"
      filesep="#6#;#4#;#6#"+";#9#;#6#"
      dirnamesep="#7#;#9#;#6#"+";#7#;#5#"
      finalsep="#8#;#2#;#5#"+";#4#;#8#"
          
      f=source.split(finalsep)[0].split(filesep)
      files=[];f.each {|fi| files<<fi.split(filenamesep)}
     
      folders=source.split(finalsep)[1].split(dirnamesep)
	      
      folders.each do |d|
        Dir.mkdir(destination+"/"+d)
      end
		  
      files.each do |f|
        path=destination+"/"+f[0]
        fi=File.open(path,"w");fi.write(f[1]);fi.close
      end
		  
	  ### create first time startup data, default config and edit INSTALLATION_HEADER data
	  ###
	  f=File.open(destination+"/rubin/system/rubin.rb","r");source=f.read;f.close
	  src=source.split("\n")[1..-1]
		  
	  ##edit install header
	  user=ENV["USER"]		  
	  header=["installed",destination+"/Rubin",Time.now.to_s,user.to_s,rand(100000000000).to_s(16)]
	  header="INSTALLATION_HEADER="+header.to_s
		  
	  src.insert(0,header)
	  source=src.join("\n")
		  
	  f=File.open(destination+"/rubin/system/rubin.rb","w");f.write(source);f.close
		  
	  ## set up cache and config
		  
	  ###########
	  install_complete=true
	  
    else; install_complete= "ERROR: Destination already has an installation."
	end
  else; install_complete= "ERROR: Destination directory is not writable."
  end

end

if install_complete==true
  puts "Rubin installation complete. You can now close this window or it will close in 5 seconds."
else
  puts "Installation did not complete sucessfully. This window will now close in 5 seconds."
end  

sleep 5  
exit

##install source file below this seperator
#43#;#77#;#43#;#23#;#45#;#65#;#77#;#04#;#75#