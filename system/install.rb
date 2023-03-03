class Installation_Manager
  def initialize
    	   
	@default_index_package=[["/rubin/system/daemond.rb",
	  "/rubin/system/apps.rb",
	  "/rubin/system/controller.rb",
	  "/rubin/system/definitions.rb",
	  "/rubin/system/dictionary.rb",
	  "/rubin/system/host.rb",
	  "/rubin/system/install.rb",
	  "/rubin/system/instance.rb",
	  "/rubin/launch.rb",
	  "/rubin/launch irb.cmd",
	  "/rubin/system/network.rb",
	  "/rubin/system/rubin.rb",
	  "/rubin/system/ruby.rb",
	  "/rubin/data/scripts/adaptedstartup.rb",
	  "/rubin/data/scripts/systemlogmonitor.rb",
	  "/rubin/data/scripts/startup.rb",
	  "/rubin/data/scripts/unpackaged_installer_script.rb"],
	["/rubin/system",
	 "/rubin/app",
     "/rubin/class",
     "/rubin/data",
     "/rubin/shortcuts",
     "/rubin/data/appdata",
     "/rubin/data/backups",
     "/rubin/data/config",
     "/rubin/data/definitions",
     "/rubin/data/fileio",
     "/rubin/data/logs",
     "/rubin/data/scripts",
     "/rubin/data/sys",
     "/rubin/data/sys/instance",
     "/rubin/data/temp",
     "/rubin/data/user"]]
    	
  end
  
  def default_index; return @default_index_package;  end
  
  def id; return INSTALLATION_HEADER[5]
  end
  def dir; return INSTALLATION_HEADER[1]
  end
  def verify_dir;return INSTALLATION_HEADER[1].to_s.downcase==SYSTEM.homedir.to_s.downcase
  end
  def date; return INSTALLATION_HEADER[3]
  end
  def version; return INSTALLATION_HEADER[2]
  end
  def verify_installation_files(path)
    if path.to_s.downcase.split("/")[-1]=="rubin"
	  if File.file?(path+"/system/rubin.rb");return true;end
	end
	return false
  end
  
  def default_build_package
    a=self.default_index[0];  b=self.default_index[1]
    self.build_package(a,b)
  end
  
  
  ## build a source package file from installed version
  def build_package *args #(included_files,included_dir_paths)     
    included_files=args[0]
	included_dir_paths=args[1]
    files_data=[]
	maindatasep="#1#::#1#::#0#::#0#::#0#"+"::#1#::#1#"
	filenamesep="#1#::#1#::#0#::#0#::#0#"+"::#0#::#1#"
	filesep="#1#::#1#::#0#::#0#::#0#"+"::#0#::#0#"
    index_sep="#1#::#0#::#0#::#0#::#0#"+"::#"+"0#::#1#"
    
	##get index file paths
    index_files=[]
	included_files.each do |f|
	  p=f.to_s.downcase.split("/rubin/")[-1]
	  index_files << "/rubin/"+p
	end
	
	## locations of actual resources
	nincluded_files=[]
	included_files.each do |f|
	  p = f.to_s.downcase.split("/rubin/")[-1]
	  nincluded_files << INSTALLATION_HEADER[1].to_s+"/"+p
	end
	
	included_files=nincluded_files
    
	##get index dir paths 
	index_dirs=[]
	included_dir_paths.each do |d|
	  p=d.to_s.downcase.split("/rubin/")[-1]
	  index_dirs << "/rubin/"+p
	end

    ##make index string
    index1=index_files.join("?")
    index2=index_dirs.join("?")
    index=index1+"??"+index2
    
	## get data of all the files
    files_data=[]
	included_files.each do |f|
	  f=File.open(f,"r");files_data << f.read ;  f.close
	end
	
	##combine files data with their index paths
	nfiles_data=[]
	files_data.each do |fd|
	  i=files_data.index(fd)
	  p=index_files[i.to_i]
	  da=""+p.to_s+filenamesep+fd.to_s
	  nfiles_data << da
	end
	
	filespkg = nfiles_data.join(filesep)
	
    final_data = maindatasep.to_s + index.to_s + index_sep.to_s + filespkg.to_s
	
	final_data=final_data.split("\n").join(";;"+";;;")
	
	d=SYSTEM.datadir+"/backups/installpackage.txt"
	
	f = File.open(d,"w");f.write(final_data);  f.close
	
	return "Your file was built: "+d.to_s

  end

  #install.install_package("E:/Rubin/data/backups/installpackage.txt","C:/Users/14809/Desktop")

  def install_package(package,dir)
    if self.verify_installation_files(dir) == true ;  raise "Rubin is already installed there.";   end
    if File.file?(package) == false;  raise "Input file path is incorrect.";  end
	
	##load data
	f=File.open(package,"r"); data = f.read ; f.close
	
	##decode data
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
	load ""
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
    return true 
  end
 
 
  
 
   
   ## Internet enabled methods
  
   # def pull_file(url) ## pulls raw files from github   
   # end
   # def verify_file(path,url)  ## checks a file against its github counterpart, true if same.
   # end
   # def  check_latest_version   ## checks the rubin website for the latest version number
   # end
 
 
end