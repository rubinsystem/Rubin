#self.rb#5#;#6#;#9#;#9#;#4#;#5#;#6#;#7#;#9#;#6#;#4##
## ossy7.20


## all 256 ascii characters
CHARS = [] ; c = 0 ; 256.times{ CHARS << c.chr.to_s ; c += 1 }
## every 8 bit binary number in cardinal order
BINARY = [] ; c = 0 ; 256.times {  b = c.to_s(2) ; until b.to_s.length == 8 ; b = "0" + b.to_s ; end ; BINARY << b ; c += 1 }
## every hexicdeimal number in order
HEX = [] ; c = 0 ; 256.times { h = c.to_s(16) ; if h.length == 1 ; h = "0" + h.to_s ; end ; HEX << h ; c += 1 }
## a list of all 8 bit byte codes for the ascii characters
#BYTES = [] ; HEX.each do |h| ; BYTES << "\\x" + h ; end
##system/region termonology
DAYS = ["sunday","monday","tuesday","wednesday","thursday","friday","saturday"]
MONTHS = ["january","february","march","april","may","june","july","august","september","october","november","december"]
SEASONS = ["spring","summer","autum","winter"]

$CHARS = CHARS
$BINARY = BINARY
$HEX = $HEX

TIMEZONES=[""]
COLORS=[] ## color names(only primary colors)
COLORP=[] ## color hex values
UNITS=[] #(OF METRIC)
UNITSAB=[] #above units abbreviations
KEYWORDS=[] ## all default ruby syntax keywords plus ossy ones
EXECPS=[] ## Exception types


## some nifty methods for fooling around
def _and(a,b) ; if a == 1 and b == 1 ; return 1 ; else ; return 0 ; end ; end
def _or(a,b) ; if a == 0 and b == 1 or a == 1 and b == 0 ; return 1 ; else ; return 0 ; end ; end
def _not(a,b) ; if a == 0 and b == 0 ; return 1 ; else ; return 0 ; end ; end
def _nor(a,b) ; if a == 0 and b == 0 or a == 0 and b == 1 or a == 1 and b == 0 ; return 1 ; else ; return 0 ; end ; end
def _nand(a,b) ; if a == 1 and b == 1 or a == 0 and b == 0 ; return 1 ; else ; return 0 ; end ; end
def _xor(a,b) ; if a == 0 and b == 1 or a == 1 and b == 0 or a == 1 and b == 1 ; return 1 ; else return 0 ; end ; end
## random string to compliment random number method
def rands(*int);if int[0].to_i>=2;t=int[0].to_i;else;t=1;end;s='';t.times{s='';s<<rand(255).chr};return s;end
## figure out what os the interpreter is on


## determine if host is windows, regardless of what it tells the interpreter by actually looking at memory and files
def windows_host?;if ENV["OS"] == "Windows_NT" and File.directory?("C:/");return true;end;end
## why in gods name is this not a method or at least alias in Object
def time;Time.now;end
def date;;end
def internet?;;end ## use open uri to attempt to connect to the internet

def bench_mark(str,cont)
  s=Time.now
  begin;cont.instance_eval(str.to_s);return Time.now-s
  rescue => e;return "Exception: \n"+e.to_s+"\n"+e.backtrace[0..1].join("\n")
  end
end
alias :bm :bench_mark

def eval_input *args
  estr="{exit}";  lines=[]
  if args.length==1;cont=args[0];  else;  cont=self;  end
  loop do
    line=gets.chomp
	if line.to_s=="{exit}";  break
	else;  lines << line.to_s
	end
  end
  code=lines.join("\n")+"\n"
  begin;  res = cont.instance_eval(code)
  rescue => e;  res=e.to_s+"\n"+e.backtrace.join("\n")
  end
  return res
end

#####################################################################################################################################################################################
## this stuff is for objects that need their parent class to have a method or alias name, class or other objects
## basically the stuff you define here is in the context of every class object hereafter
Object.class_eval{
  def local_methods ; ms = self.methods ; mets = [] ; ms.each { |m| mets << m.to_s } ; rm = self.class.methods ; self.class.class.methods.each { |m| rm << m.to_s } ; nm = [] ; mets.each { |m| unless rm.include?(m.to_s) ; nm << m.to_s ; end } ; return nm ; end
  alias :m :methods ; alias :lm :local_methods
  alias :lv :local_variables ; alias :gv :global_variables ; alias :iv :instance_variables
  alias :ivs :instance_variable_set ;   alias :ivg :instance_variable_get   ##dont forget get/set constants and classvariables
  alias :iev :instance_eval ; alias :ev :eval
  def constants ; MAIN.class.constants ; end ; alias :cn :constants
}
#8#;#3#;#5#;#3#;#1#;#8#;#3#;#5#;#3#;#8#;#5##array.rb#5#;#6#;#9#;#9#;#4#;#5#;#6#;#7#;#9#;#6#;#4## Array redefinition
# ossy7.20
# We only add one method so far, a visual of .to_s

Array.class_eval{

  def delete_clones
    na=[]
	a=self
	a.each { |i| if na.include?(i) == false ; na << i ; end}
    return na
  end

  def syntax  ## pretty much the same as Array.class.to_s but now you can read the code :D (some objects need to have support added if you want to use them like Method or Enumurator)
    items = []
    self.each do |o| 
      if [Integer,Fixnum,Bignum,Float,Range,Hash].include?(o.class) ; items << o.to_s
	  elsif o.is_a? String ; items << "\"" + o.to_s + "\""
	  elsif o.is_a? Symbol ; items << ":" + o.to_s
	  elsif o == true ; items << "true"
	  elsif o == false ; items << "false"
	  elsif o == nil ; items << "nil"
	  elsif o == [] ; items << "[]"
	  elsif o.is_a?(Symbol) ; items << ":"+o.to_s
	  elsif o.is_a?(Array) ; items << o.to_s
	  elsif o.is_a?(Class) ; items << o.inspect.to_s  ## because of this watchout for accidentally pushing classes into arrays instead of the data they were to return
	    begin;s=o.to_s
		rescue;s=''
		end
		items<<s
      end	  
	end
    "[" + items.join(", ").to_s + "]"
  end
  ##alias :to_s :syntax  ##use this to hijack Array objects .to_s method
}#8#;#3#;#5#;#3#;#1#;#8#;#3#;#5#;#3#;#8#;#5##bignum.rb#5#;#6#;#9#;#9#;#4#;#5#;#6#;#7#;#9#;#6#;#4## Bignum redefinition
# ossy7.20
# Integers that are also Bignum store their methods here rather than in Integer

##BIGNUM MAY BE DEPRECIATED
# Bignum.class_eval{
  # def commas  ##format large numbers with commas
    # str = ""
    # s = self.to_s.split("").reverse ; i=0
    # s.each do |nc|
      # if i == 2
        # i=0 ; str << nc.to_s + ","
      # else
	    # str << nc.to_s ; i+=1 
	  # end 
    # end
    # if str.to_s[-1].chr.to_s == ","
  	  # str = str.reverse.to_s.split("")[1..-1].join("").to_s
    # else
  	  # str = str.reverse.to_s
    # end
    # return str.to_s
  # end 
  # alias :com :commas  ## make this crap shorter to type and annoying for linux programmers cause im a dick
#}
#8#;#3#;#5#;#3#;#1#;#8#;#3#;#5#;#3#;#8#;#5##database.rb#5#;#6#;#9#;#9#;#4#;#5#;#6#;#7#;#9#;#6#;#4### BRING DEX.RB OVER HERE AND GENERALIZE IT FOR DICTIONARY BUILDING#8#;#3#;#5#;#3#;#1#;#8#;#3#;#5#;#3#;#8#;#5##dir.rb#5#;#6#;#9#;#9#;#4#;#5#;#6#;#7#;#9#;#6#;#4## Dir redefinition
# ossy7.20
##
##  Dir.exist?(String)
##  Dir.image(String)
##  Dir.build_image(String,String)
##  Dir.dir *args
##  Dir.view *args
##  Dir.map(String)
##  Dir.size?(String)
##  Dir.empty?(String)
##  Dir.empty!(String)
##  Dir.delete(String)  ##add this already
##  Dir.search *args
##  Dir.copy(String,String)
##  Dir.move(String,String)
##  Dir.rename(String,String)
##  Dir.locate *args
##  Dir.clones?       ##this works different than File.clones?
##  
##


Dir.instance_eval{

  def exist? inp ##i cant believe this isnt already a thing what if i just learned ruby and im like oh the exist? method is in Dir
    File.exist?(inp)
  end
 

  def image(dir,dest,fname)
    
	begin
	
	name=dir.to_s.split("/")[-1]
    map=Dir.map(dir.to_s)
	files=map[0]
	dirs=map[1]#.sort_by {|x| x.length} #might depend on order mapped to be validly creatable in list order
	
	nd=[]
	dirs.each do |d|
	  s=d.split("/"+name+"/")[1..-1].join("/"+name+"/")
	  nd<<s
	end
	dirs=nd
	
	#make string of all dirs
	datasep="?*?"+"*?"
	dir_tree=dirs.join(datasep)
	
	##read all the files
    file_data=[]
	datasep="#4#:::"+"#4#:"+"::#4#:::#4#:::#1#"
	files.each do |f|
	  fp = f.split("/"+name+"/")[1..-1].join("/"+name+"/")	
	  ff=File.open(f,"rb");file_data<<[fp,datasep,ff.read].join('');ff.close
	end
    
	##join all the files
	datasep="#7#:::"+"#7#:"+"::#7#:::#7#:::#3#"
    file_data=file_data.join(datasep)
	
	#make final image string
	datasep=("#1#:::"+"#1#:::#1#:::#1#:::#1#")
    img=file_data+datasep+dir_tree
	
	#write image file
	path=name+"-image-"+fname.to_s+".dim"
	f=File.open(dest+"/"+path,"wb");f.write(img);f.close
	
	rescue;return false
    end
	
	return true
	
  end
 
  def build_image(path,dest)
    if File.file?(path.to_s) and path.to_s.split(".")[-1].downcase=="dim"
      if File.dir?(dest.to_s) 
		name=path.to_s.split("-image")[0].split("/")[-1]
	    f=File.open(path,"rb");img=f.read;f.close
        
		#split image into filedata and dirs
	    datasep="#1#:::"+"#1#:::#1#:::#1#:::#1#"
		img=img.split(datasep)
		
		#split apart directory list
		file_data=img[0]
		datasep="?*?"+"*?"
		dir_tree=img[1].split(datasep)
		
        #split files apart
        datasep="#7#:::"+"#7#:"+"::#7#:::#7#:::#3#"
        files=file_data.split(datasep)
		
		#split file data and paths from eachother 
		file_data=[]
		datasep="#4#:::"+"#4#:"+"::#4#:::#4#:::#1#"
		files.each {|f| file_data<< f.split(datasep)}
		
		$f=file_data
		
		#make all dirs
        path=dest+"/"+name
		Dir.mkdir(path)
        dir_tree.each do |d|
		  begin
		  Dir.mkdir(path+"/"+d)
		  rescue
		  end
		end
		
		#make all files
		file_data.each do |fd|
		  fpath=path+"/"+fd[0]
		  f=File.open(fpath,"wb");f.write(fd[1]);f.close
		end
		
		return true
	  
	  else;raise "Destination directory doesnt exist.!";return false
	  end
    else;raise "Method arg[0] must be a dim file.";return false
    end
  end 

  def dir *args ## Dir.chdir and Dir.getwd are now in the same method, pass no arguement to get directory and a name of a subdirectory, whole directory or even '..' to change directory 
    if args.length==0;return Dir.getwd.to_s
    elsif args[0].is_a?(String)
      if File.directory?(args[0]) ; Dir.chdir(args[0]) ; return Dir.getwd.to_s
      elsif File.directory?(Dir.getwd.to_s + "/" + args[0].to_s) ; Dir.chdir(Dir.getwd.to_s + "/" + args[0].to_s) ; return Dir.getwd.to_s
	  else ; raise "No such directory."
      end
    end
  end
  
  def view *args ## prints directory contents to screen
    if args[0] == nil
	  dir = Dir.getwd.to_s
    elsif File.directory?(args[0].to_s)
      dir = args[0].to_s  
    elsif File.directory?(Dir.getwd + args[0])
      dir = Dir.getwd + args[0]
    else
      dir = false
    end
    if dir == false ; raise "No such directory: " + args[0].to_s
    else 
	    cont = Dir.entries(dir.to_s) ; cont.delete(".") ; cont.delete("..") ; bt = 0
		if cont.length == 0 ; return  "Directory is empty" 
	    else
		  str = [] ; fi = [] ; fo = []
		  cont.each do |p|
		    if File.file?(dir.to_s + "/" + p.to_s)
		              begin ; s = File.size?(dir.to_s + "/" + p.to_s).to_s ; rescue ; s = "" ; end
			  fi << "File: " + p.to_s + "    Size: " + s.to_s
		    elsif File.directory?(dir.to_s + "/" + p.to_s)
			  fo << "Dir:  " + p.to_s + ""
			end
		  end
		  str << "Directory:   \"" + dir.to_s + "\"   Files: " + fi.length.to_s + ", Folders: " + fo.length.to_s
		  str << "#############################################"
		  fo.each { |f| str << f.to_s } ; fi.each { |f| str << f.to_s }
		  str << "#############################################\n"
		  puts str.join("\n").to_s
		end
    end
  end
  
  def map(dir)
     if File.directory?(dir.to_s) or File.directory?(Dir.getwd.to_s + "/" + dir.to_s)
      if File.directory?(dir.to_s) ; ; else ; dir = Dir.getwd.to_s + "/" + dir.to_s ; end
      cur = nil ; rem = [dir.to_s] ; fi = [] ; fo = [] ; ex = []
      until rem.length == 0
        cur = rem[0].to_s ; rem.delete_at(0)
        begin ; cont = Dir.entries(cur.to_s) ; cont.delete(".") ; cont.delete("..")
          if cont.length > 0
             cont.each do |p|
               if File.file?(cur.to_s + "/" + p.to_s) ; fi << cur.to_s + "/" + p.to_s
               elsif File.directory?(cur.to_s + "/" + p.to_s) ; fo << cur.to_s + "/" + p.to_s ; rem << fo[-1]
               end
             end
          end
        rescue
          ex << cur
        end
      end
      if ex.length == 0 ; return [fi,fo]
      else ; return [fi,fo,ex]
      end
	elsif File.file?(dir.to_s) ; return "Arguement is a file. Dir.map returns arrays of subdirectories and files with in a directory, it does not work on files."
    else
      raise "No such directory"
    end
  end
  
  def size?(dir) ## gets the size of an entire directory
    if File.directory?(dir)
      m = map(dir)
      if m.length == 2
        s = m[0].join('').length + m[1].join('').length
        if m[0].length > 0
          m[0].each do |f|
            s += File.size?(f)
          end
        end
        return s
      else
        raise "Directory can not be measured because it contained unreadable subdirectories: " + m[2].join(", ").to_s
      end
	elsif File.file?(dir.to_s) ; return File.size?(dir.to_s)
    else ; raise "No such file or directory."
    end 
  end
  
  def empty?(dir)
    if File.directory?(dir) ; if Dir.entries(dir.to_s).length <= 2 ; return true ; else ; return false ; end
	elsif File.file?(dir) ; return File.empty?(dir.to_s)
	else ; return "No such file or directory."
	end
  end
  
  def empty!(dir) # deletes everything in a directory before deleting it
    failed=[]
    map=Dir.map(dir)
	map[0].each {|f| begin;File.delete(f);rescue;failed<<f;end }
	dirs=map[1].reverse
    dirs.each do |d|
	  begin;Dir.delete(d)
	  rescue;failed<<d
	  end
	end
    if failed.length==0;return true
	else;return failed
	end
  end  

  def delete!(dir)
    if self.empty!(dir)
      Dir.delete(dir)
	  return true
	else;return false
	end
  end

  
  ##THIS METHOD NEEDS SOME FUCKING TLC COME ON 20 YEAR OLD JACOB!
  ## searches for files with a name or contents specified
  def search *args # dir, tag, filebytes, ignorecase
    if args[0].is_a?(String) and File.directory?(args[0].to_s)
	  if args[1].to_s.length > 0
	    found_files = []; found_folders = [] ; found_file_pages = [] ; map = Dir.map(args[0].to_s)
        if map[1].length > 0
		  map[1].each do |dir|
		    if args[3] == true ; d = dir.to_s.downcase ; term = args[1].to_s.downcase
			else ; d = dir.to_s ; term = args[1].to_s
			end ; if d.to_s.include?(term.to_s) ; found_folders << dir.to_s ; end
		  end
		end		
		if map[0].length < 0
		  map[0].each do |path|
		    if args[3] == true ; p = path.to_s.downcase ; term = args[1].to_s.downcase
			else ; p = path.to_s ; term = args[1].to_s
			end ; if p.to_s.include?(term.to_s) ; found_files << p.to_s ; end	    
			if args[2] == true
			  fi = File.open(path.to_s,"r") ; cont = fi.read.to_s ; fi.close
			  if args[3] == true ; cont = cont.to_s.downcase ; term = args[1].to_s.downcase
			  else ; cont = cont.to_s ; term = args[1].to_s
			  end
			  if cont.to_s.include?(term.to_s) 
			    position = cont.to_s.downcase.split(term.to_s.downcase)[0].to_s.length
			    found_file_pages << [path.to_s,position.to_i]
			  end
			end
		  end		
		end
        res = [found_files,found_folders,found_file_pages]
		if args[2] == true ; return res
		else
          if res[0].length == 0 and res[1].length == 0 ; return "No instances of the term were found in the given directory."
		  else ; return res[0..1]
		  end
		end
	  else	  ; return "No search term was given."
	  end
	elsif File.file?(args[0].to_s)
	  if args[1].to_s.length > 0 ; return File.search(args[0].to_s,args[1].to_s)
	  else ; return "No search term was given."
      end	  
	else ; if args.length == 0 ; return "Enter arguements: (dir, tag)" ; else ; return "No such file or directory." ; end
	end
  end
  
  def copy(dir,newdir) ## copy utility
    if File.directory?(dir)
      if File.directory?(newdir.to_s + "/" + dir.to_s.split("/")[-1].to_s) == false
	    m = Dir.map(dir.to_s)
		if m == [[],[]]
		  Dir.mkdir(newdir.to_s + "/" + dir.to_s.split("/")[-1].to_s)
		else ; Dir.mkdir(newdir.to_s + "/" + dir.to_s.split("/")[-1].to_s)
		  if m[1].length > 0
		    m[1].each do |d|
			  nd = newdir.to_s + "/" + d.to_s.split(dir.to_s)[1].to_s
			  Dir.mkdir(nd.to_s)
			end
		  end
		  if m[0].length > 0
		    m[0].each do |p|
			  fi = File.open(p.to_s,"r") ; cont = fi.read.to_s ; fi.close
			  np = newdir.to_s + "/" + p.to_s.split(dir.to_s)[1].to_s
			  fi = File.open(np.to_s,"w") ; fi.write(cont.to_s) ; fi.close
			end
		  end
		end
	    return true
	  else ; return "Target directory already contains a directory with the same name as the one you're copying."
	  end
	else ; return "No such directory."
	end
  end
  
  def move(dir,newdir) ## move utility
    if File.directory?(dir)
      if File.directory?(newdir)
	    if File.directory?(newdir.to_s + "/" + dir.to_s.split("/")[-1].to_s) == false
		  Dir.mkdir(newdir.to_s + "/" + dir.to_s.split("/")[-1].to_s)
		  img = Dir.img(dir.to_s)
		 if img == [[],[],[]] ; Dir.delete(dir.to_s) ; return true
		  else
		    Dir.copy(dir.to_s,newdir.to_s)
		    if img[0].length > 0
			  img[0].each { |f| File.delete(f.to_s) }
			end
		    if img[1].length > 0
			  img[1].each { |d| Dir.delete(d.to_s) }
			end
			Dir.delete(dir.to_s)
			return true
		  end
		else ; return "Cannot move because target directory already exists."
		end
	  elsif File.file?(newdir) ; return "Target directory is actually an existing file!"
      else ; return "Target directory does not exist."
      end	  
	elsif File.file?(dir) ; return "Dir.move is for directories only, use File.move for files."
    else ; return "No such directory."
	end
  end

  ## rename utility, this ones a bitch to do efficiently dont expect it anytime soon  
  def rename(dir,newname) 
  
  end


  ## find a file or folder in directory and return path
  def locate *args # dir, name
    if File.directory?(args[0].to_s)
	  found = []
	  map = Dir.map(args[0].to_s)
	  if map == [[],[]] ; return "The target directory is empty."
	  else
	    if map[0].length > 0
		  map[0].each do |path|
		    if path.include?(args[1].to_s) ; found << path.to_s ; end
		  end		  
		end
	    if map[1].length > 0
		  map[1].each do |dir|
		    if dir.include?(args[1].to_s) ; found << dir.to_s ; end
		  end
		end
	  end
	  if found.length == 0 ; return false
	  else
	    if found.length == 1 ; return found[0].to_s ; else ; return found ; end
	  end
	else ; return "No such directory."
	end
  end
  
  ## search a directory for duplicate file data and make a list of paths if found
  ## i dont think ive ever tested this pretty sure its broken
  def clones? *args # dir
    if File.directory?(args[0].to_s)
	  m = Dir.map(args[0].to_s)
	  if m == [[],[]] ; return "Target directory is empty."
      else
		dat = [] ; m[0].each { |f| dat << File.read(f).to_s }
		same = []
		until dat.length == 0
		  obj = dat[0].to_s ; dat.delete_at[0] ; path = m[0] ; m.delete_at(0)
		  if dat.include?(obj.to_s)
		    same << path.to_s
		    same << m[dat.index(obj.to_s)].to_s
            m[0].delete_at(dat.index(obj.to_s))
            dat.delete_at(dat.index(obj.to_s))
		  end		
		end
		if same.length == 0 ; return false
		else ; return same
		end
      end	  
	else ; return "No such directory."
	end
  end
   

  alias :make :mkdir
}

##this is the same context as self but self is usually defined first and these depend on this class so they have to be after it
def dir *args ; Dir.dir *args ; end
def viewdir *args ; puts Dir.view *args ; end
alias :vd :viewdir
#8#;#3#;#5#;#3#;#1#;#8#;#3#;#5#;#3#;#8#;#5##file.rb#5#;#6#;#9#;#9#;#4#;#5#;#6#;#7#;#9#;#6#;#4## File redefinition
# ossy7.20

# File.make(String path)
# File.print(String path)
# File.view(String path)
# File.prepend(String path,String string)
# File.append(String path, String string)
# File.insert(String apth, Integer pos, String string)
# File.read_line(String path, Integer/Range line)
# File.write_line(String path, Integer line, String string)
# File.insert_line(String path, Integer line, String string)
# File.get_lines(String path)
# File.delete_line(String path, Integer line)
# File.include?(String path, String string)
# File.empty?(String path)
# File.empty!(String path)
# File.size?(String path)
# File.copy(String path, String newpath)
# File.move(String path, String newpath)
# File.dir?(String path)
# File.file?(String path)
# File.open(String path, String method)
# File.read(String path)
# File.write(String path, String string)
# File.close


File.instance_eval{
  #def read(path) ; ; end ## ossy hasnt actually had a good reason to redefine read for a long time now this is about to be removed
  #plus the problem is when you open a file its class has a read method as instance instead of global class so
 #figure that shit out before we reinclude read and write/print

  def make(path);f=File.open(path,"wb");f.close;return true;end

  def print(path)  ## print file to screen
	unless File.file?(path)==false
	  print File.read(path)
	end
  end
  
  def view(path)
    unless File.file?(path)==false
      puts File.read(path)
	end
  end
  
  def prepend(path,string)
    
  end
  
  ## eliminates the need to open files in "a" mode but problematic for massive file.
  def append *args # path, str
    if File.file?(args[0].to_s)
	  if args[1].to_s.length > 0
	    fi = File.open(args[0].to_s,"r") ; cont = fi.read.to_s ; fi.close
		fi = File.open(args[0].to_s,"w") ; fi.write(cont.to_s + args[1].to_s) ; fi.close
	    return true
	  else ; return "No input string to append to file."
	  end
	else ; return "No such file."
	end
  end
  
  ## insert string at given character index position (0=first character)
  def insert *args # path, pos, str
    if File.file?(args[0].to_s)
	  if args[1].is_a?(Integer)
	    fi = File.open(args[0].to_s,"r") ; cont = fi.read.to_s ; fi.close
		cont = cont.split('')
        inserted = cont[0..args[1].to_i].join('').to_s + args[2].to_s + cont[(args[1].to_i+1)..-1].join('')
		fi = File.open(args[0].to_s,"w") ; fi.write(inserted.to_s) ; fi.close
		return true
	  else ; return "Specified position is not a valid integer."
	  end
	else ; return "No such file."
	end
  end

  # get a paticular line from a file in one call, line can be an integer or valid range of line index numbers
  def read_line *args # path, line
    if File.file?(args[0].to_s)
	  fi = File.open(args[0].to_s,"r") ; lines = fi.read.to_s.split("\n") ; fi.close ; lines.delete("")
      if lines.length > 0
        if args[1].is_a?(Integer) or args[1].is_a?(Range)
		  if args[1].is_a?(Integer)
            return line[args[1].to_i].to_s
          elsif args[1].is_a?(Range) 
		    return lines[args[1]].join("\n").to_s
		  end
		else ; return "Invalid line index given."
		end
      else ; return "File is empty so there were no lines to retrieve."
      end
	else ; return "No such file."
	end
  end
  
  #write over a paticular line or lines, like above pos can be a range
  def write_line *args # path, line, string
    if File.file?(args[0].to_s)
	  if args[1].is_a?(Integer) or args[1].is_a?(Range)
	    if args[2].is_a?(String) and args[2].to_s.length >= 1
		  fi = File.open(args[0].to_s,"r") ; cont = file.read.to_s.split("\n") ; fi.close
		  cont[args[1]] = args[2].to_s
		  fi = File.open(args[0].to_s,"w") ; fi.write(cont.join("\n").to_s) ; fi.close
		  return true
		else ; return "No input string to write on line."
		end
	  else ; return "Invalid Line specification."
	  end
	else ; return "No such file."
	end
  end
  
  ##inserts a line at one or more lines, line breaks not allowed..i think...?
  def insert_line *args # path, line, str
    if File.file?(args[0].to_s)
	  if args[1].is_a?(Integer) or args[1].is_a?(Range)
	    if args[2].is_a?(String) and args[2].to_s.length >= 1
		  fi = File.open(args[0].to_s,"r") ; cont = file.read.to_s.split("\n") ; fi.close
		  d = cont[0..args[1].to_i] ; d << args[2].to_s
		  #cont[(args[1].to_i+1)..-1].each do |l| ; { d << l } ; end
		  fi = File.open(args[0].to_s,"w") ; fi.write(d.join("\n").to_s) ; fi.close
		  return true
		else ; return "No input string to write on line."
		end
	  else ; return "Invalid Line specification."
	  end
	else ; return "No such file."
	end
  end
  
  ## deletes a line FUCK ADD RANGE SUPPORT
  def delete_line *args # path, line
    if File.file?(args[0].to_s)
	  if args[1].is_a?(Integer)
        fi = File.open(args[0].to_s,"r") ; lines = fi.read.to_s.split("\n") ; fi.close
		lines.delete_at(args[1])
        fi = File.open(args[0].to_s,"w") ; fi.write(lines.join("\n").to_s) ; fi.close
		return true
	  else ; return "Invalid line specification, please enter an integer."
	  end
	else ; return "No such file."
	end
  end
  
  ## just get all the lines in a file as an array
  def get_line *args # path
    if File.file?(args[0].to_s) ; fi = File.open(args[0].to_s,"r") ; cont = fi.read.to_s.split("\n") ; fi.close ; return cont
	elsif File.directory?(args[0].to_s) ; return "Input string is a directory, File.get_lines only works on files."
    else ; return "No such file."
    end  
  end
  
  ##works like String.include? but the String is a File instead
  def include? *args
    if File.file?(args[0].to_s)
	  if args[1].to_s.length > 0 ; fi = File.open(args[0].to_s) ; cont = fi.read.to_s ; fi.close ; return cont.to_s.include?(args[1].to_s)
	  else ; return "No input string."
	  end
	elsif File.directory?(args[0].to_s) ; return "File.include? is for files, not directories."
	else ; return "No such file."
    end
  end
  
  ##delete file contents
  def empty!(path)
    if File.file?(path.to_s)
	  if File.size?(path.to_s) > 0 ; fi = File.open(path.to_s,"w") ; fi.write('') ; fi.close ; return true
	  else ; return "File is already empty."
	  end
	elsif File.directory?(path.to_s) ; return "File.empty! is for files, not directories, use Dir.empty! if you want to delete all the contents of a directory."
	else ; return "No such file."
    end    
  end
  
  ## true if file size 0
  def empty?(path)
    if File.file?(path.to_s)
	  fi = File.open(path.to_s,"r") ; cont = fi.read.to_s.split('').length ; fi.close
	  if cont == 0 ; return true ; else ; return false ; end
	elsif File.directory?(path.to_s) ; return "File.empty? is for files, use Dir.empty for directories."
    else ; return "No such file."
    end    
  end
  
   #def size?(path)
   #  f=File.open(path,"rb");size=f.read.to_s.split('').length;f.close;return size
   #end
  
  ## copy utility
  def copy *args #path, newpath
    if File.file?(args[0].to_s)
	  if File.directory?(args[1].to_s)
	    if File.file?(args[1].to_s + "/" + args[0].to_s.split("/")[-1].to_s) == false
	      fi = File.open(args[0].to_s,"rb") ; cont = fi.read.to_s ; fi.close
		  fi = File.open(args[1].to_s + "/" + args[0].to_s.split("/")[-1].to_s,"wb") ; fi.write(cont.to_s) ; fi.close
          return true		  
		else ; return "Target directory already contains a file with the same name."
		end
	  else ; return "Input target directory is invalid."
	  end
	else ; return "No such file."
	end  
  end
  
  #move utility
  def move *args #path, newpath
    if File.file?(args[0].to_s)
	  if File.directory?(args[1].to_s)
	    if File.file?(args[1].to_s + "/" + args[0].to_s.split("/")[-1].to_s) == false
	      fi = File.open(args[0].to_s,"rb") ; cont = fi.read.to_s ; fi.close
		  fi = File.open(args[1].to_s + "/" + args[0].to_s.split("/")[-1].to_s,"wb") ; fi.write(cont.to_s) ; fi.close
		  File.delete(args[0].to_s)
          return true		  
		else ; return "Target directory already contains a file with the same name."
		end
	  else ; return "Input target directory is invalid."
	  end
	else ; return "No such file."
	end  
  end 
  
  alias :dir? :directory?
}
#8#;#3#;#5#;#3#;#1#;#8#;#3#;#5#;#3#;#8#;#5##fixnum.rb#5#;#6#;#9#;#9#;#4#;#5#;#6#;#7#;#9#;#6#;#4## Fixnum redefinition
# ossy7.20
# Integers that are fixnum store their methods here rather than Integer

# Fixnum.class_eval{
  # def commas  ##format large numbers with commas
    # str = ""
    # s = self.to_s.split("").reverse ; i=0
    # s.each do |nc|
      # if i == 2
        # i=0 ; str << nc.to_s + ","
      # else
	    # str << nc.to_s ; i+=1 
	  # end 
    # end
    # if str.to_s[-1].chr.to_s == ","
  	  # str = str.reverse.to_s.split("")[1..-1].join("").to_s
    # else
	  # str = str.reverse.to_s
    # end
    # return str.to_s
  # end
  
  # alias :com :commas ## make this crap shorter to type and annoying for linux programmers cause im a dick
# }
#8#;#3#;#5#;#3#;#1#;#8#;#3#;#5#;#3#;#8#;#5##integer.rb#5#;#6#;#9#;#9#;#4#;#5#;#6#;#7#;#9#;#6#;#4## Integer redefinition
# ossy7.20
# Here we add exponate, factors and prime? which ruby should already have a dozen such methods out of the box if you ask me

Integer.class_eval{

  def exponate ## manually search for the exponate form of the integer
    n = self ; c=2 ; e=2 ; r = [0,0]
    until c > n.to_i
      e = 2
      until e >= n.to_i ; if c**e == n.to_i ; return [c,e] ; end ; e += 1 ; end
      c += 1
    end
  end
  
  def factors ## manually search for the factors of the integer and return the first one found
    n = self ; p = [2] ; vn = 2
    until vn == n
      vn += 1
      p << vn
    end
    p.delete_at(-1)
    f1 = 0 ; f2 = 0 ; pd = []
    p.each { |pn| 
      s = n.to_f / pn.to_f
      if s.to_s[-2..-1].to_s == ".0"
        pd << pn
      end
    }
    pd.each { |p|
      if p * p == n
        f1, f2 = p, p
      else
        cd = pd
        cd.delete(p)
        cd.each { |pr| 
          if p * pr == n
            f1, f2 = p, pr
            break
          end 
        }
      end
    }
    [f1,f2]
  end
  
  def prime? ## manually check all the numbers below a number to see if only one and its self divide with out remainder.
    n=self
    rv=true;c=1;l=self-1 
    until c>=l
      c+=1
      if (self.to_f/c.to_f).to_s.split(".")[-1].to_i==0
        rv=false;c=self
      end    
    end
    rv
  end  
  
  def surname
    int=self.to_s	
	if int.to_s=="0";int="0"
	elsif int[-2..-1]=="11" or int[-2..-1] =="12" or int[-2..-1] =="13"
	  int<<"th"
    elsif int[-1]=="1";int<<"st"
    elsif int[-1]=="2";int<<"nd"
    elsif int[-1]=="3";int<<"rd"
	else;int<<"th"
	end
    return int
  end
  
  def commas  ##format large numbers with commas
    str = ""
    s = self.to_s.split("").reverse ; i=0
    s.each do |nc|
      if i == 2
        i=0 ; str << nc.to_s + ","
      else
	    str << nc.to_s ; i+=1 
	  end 
    end
    if str.to_s[-1].chr.to_s == ","
  	  str = str.reverse.to_s.split("")[1..-1].join("").to_s
    else
  	  str = str.reverse.to_s
    end
    return str.to_s
  end

}
#8#;#3#;#5#;#3#;#1#;#8#;#3#;#5#;#3#;#8#;#5##log.rb#5#;#6#;#9#;#9#;#4#;#5#;#6#;#7#;#9#;#6#;#4## Log class definition
# ossy 5
# useful log object can link to an output file or just store entries internally

class Log
  def initialize *args
    @log=[];@log_creation=Time.now
    if File.file?(args[0].to_s)
	  @path=args[0].to_s
	else
	  @path=nil
	end
  end
  def write str
    @log<<Time.now.to_s+": "+str.to_s
	if @path!=nil
	  f=File.open(@path,"a")
	  f.write(Time.now.to_s+": "+str.to_s)
	  f.close
	end
  end	
  def read
    return @log
  end
  def clear
    @log=[]
  end
  def size?
    return @log.length
  end
  alias :w :write
  alias :r :read
  alias :clr :clear
end
#8#;#3#;#5#;#3#;#1#;#8#;#3#;#5#;#3#;#8#;#5##password.rb#5#;#6#;#9#;#9#;#4#;#5#;#6#;#7#;#9#;#6#;#4## Password class definition
# ossy 5
# THIS IS NOT SECURE IN ANY WAY AND JUST TO OBFUSCATE strings from a user.

class Password
  def initialize *args
    if args[0].is_a?(String) and args[0].to_s.length > 0 and args[0].to_s.delete("abcdefghijklmnopqrstuvwxyz0123456789").empty?
	  @password = args[0].to_s.to_i(36).to_s(2) ## store the password in encoded form
	else ; raise "Enter a string with only letters and numbers."
	end
  end
  
  ##encode some input and see if it matches the encoded password
  def verify(password) ; if password.to_s.to_i(36).to_s(2) == @password ; return true ; else return false ; end ; end
  
  ## if you want the first level of security this class should deligate password changes
  def change npass
    @password = npass.to_s.to_i(36).to_s(2)
  end
  
  # get/set encoded form of the password
  def get ; return @password ; end
  def set(pw) ; @password = pw ; end
end
#8#;#3#;#5#;#3#;#1#;#8#;#3#;#5#;#3#;#8#;#5##shadow.rb#5#;#6#;#9#;#9#;#4#;#5#;#6#;#7#;#9#;#6#;#4##8#;#3#;#5#;#3#;#1#;#8#;#3#;#5#;#3#;#8#;#5##shell.rb#5#;#6#;#9#;#9#;#4#;#5#;#6#;#7#;#9#;#6#;#4## Shell class definition
# ossy 5
# For programs that want to work like irb

class Shell
  def initialize
	@context=nil
	@cid=nil
	puts "Welcome to the shell..."
  end
  def start
    @main_loop=true;@cid=0;@context=$main
	while @main_loop   ########################
	  print @context.class.to_s+":"+@cid.to_s+"<< "
	  @input = gets.chomp;res=nil
	  if @input == "exit";@main_loop=false;res="Exiting shell."
	  #elsif @input == ""
	  #elsif @input == ""
	  else
	    begin
	      res = @context.instance_eval(@input)
		rescue => e
		  res = "Input caused an exception.\n"+e.to_s+"\n"+e.backtrace.join("\n")
		end
	  end
	  print @context.class.to_s+":"+@cid.to_s+">> "+res.to_s+"\n"
	  @cid+=1
	end##this is the end of the loop ##########
  end
  
end#8#;#3#;#5#;#3#;#1#;#8#;#3#;#5#;#3#;#8#;#5##string.rb#5#;#6#;#9#;#9#;#4#;#5#;#6#;#7#;#9#;#6#;#4## String redefinition
# ossy 7.20
# Here we add many useful methods to string class

String.class_eval{
  def shuffle ; return self.split('').shuffle.join('').to_s ; end
  alias :scramble :shuffle
  def base10? ; self.delete("0123456789").empty? ; end
  alias :only_numbers? :base10?
  def base16? ; self.upcase.delete("0123456789ABCDEF").empty? ; end
  alias :only_hex? :base16?
  def base36? ; self.upcase.delete("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ").empty? ; end
  def only_letters? ; self.upcase.delete("ABCDEFGHIJKLMNOPQRSTUVWXYZ").empty? ; end  
  def to_binary ##returns a list of the binary byte form of the string from utf8 only(cause ruby)
    b = [] ; s = self.to_s.split('')
	s.each do |ch|
	  b << BINARY[CHARS.index(ch.to_s)]	
	end
	return b.join.to_s
  end
  def from_binary ## works on strings used with .to_b restoring them to ascii characters
    bytes = [] ; s = self.to_s
	until s.to_s.length == 0
	  b = s[0..7].to_s ; s = s[8..-1]
	  bytes << b.to_s
	end
	str = ''
	bytes.each do |b|
      str << CHARS[BINARY.index(b.to_s).to_i].to_s
	end
	return str.to_s
  end 
}
#8#;#3#;#5#;#3#;#1#;#8#;#3#;#5#;#3#;#8#;#5##time.rb#5#;#6#;#9#;#9#;#4#;#5#;#6#;#7#;#9#;#6#;#4## Time redefinition
# ossy7.20
# Add some methods time needs

Time.class.class.class_eval{
  def parse_seconds(s) ## take a number of second and compound it into a total of days hours minutes and seconds for timer displays and Time arithmetic
    s = s.to_s.to_f
	if s.to_f < 60.0
	  [0,0,s.to_i]
	elsif s.to_f < 3600.0 and s.to_f >= 60.0
	  minutes = s.to_f / 60.0
	  sec = ("." + minutes.to_s.split(".")[-1].to_s).to_f * 60  ## the period is because the expression is converting integers to strings to floats
	  [0,minutes.to_i, sec.round]
	elsif s.to_f < 86400.0 and s.to_f >= 3600.0
	  hours = s.to_f / 60.0 / 60.0
	  minutes = ("." + hours.to_s.split(".")[-1].to_s).to_f * 60
	  sec = ("." + minutes.to_s.split(".")[-1].to_s).to_f * 60
	  [hours.to_i, minutes.to_i ,sec.to_i]
    elsif s.to_f >= 86400.0
	  days = s.to_f / 60.0 / 60.0 / 24.0
	  hours = ("."+ days.to_s.split(".")[-1]).to_f * 24
	  minutes = ("." + hours.to_s.split(".")[-1]).to_s.to_i*60
	  sec = (s/60.0).to_s.split(".")[-1].to_i*60
	  [days,hours.to_i,minutes,sec]
	end
  end  

  def stamp *args ##get a timestamp either from current time or given time object, and convert the two back and fourth by passing them as arguements
    if args[0] == nil ; t = Time.now ; y = t.year.to_s ; mo = t.month.to_s ; d = t.day.to_s ; h = t.hour.to_s ; mi = t.min.to_s ; s = t.sec.to_s ; if y.length < 4 ; until y.length == 4 ; y = "0" + y ; end ; end ; y = y[0..3] ; 	if mo.length < 2 ; mo = "0" + mo end ; mo = mo[0..1] ; if d.length < 2 ; d = "0" + d ; end ; d = d[0..1] ; if h.length < 2 ; h = "0" + h ; end ; h = h[0..1] ; if mi.length < 2 ; mi = "0" + mi ; end ; mi = mi[0..1] ; if s.length < 2 ; s = "0" + s ; end ; s = s[0..1] ; [y,mo,d,h,mi,s].join(".")
    elsif args[0].is_a? Time ; t = args[0] ; y = t.year.to_s ; mo = t.month.to_s ; da = t.day.to_s ; hr = t.hour.to_s ; mi = t.min.to_s ; se = t.sec.to_s ; if mo.length == 1 ; mo = "0" + mo.to_s ; end ; 	if da.length == 1 ; da = "0" + da.to_s ; end ; if hr.length == 1 ; hr = "0" + hr.to_s ; end ; 	if mi.length == 1 ; mi = "0" + mi.to_s ; end ; if se.length == 1 ; se = "0" + se.to_s ; end ; return y.to_s + "." + mo.to_s + "." + da.to_s + "." + hr.to_s + "." + mi.to_s + "." + se.to_s    	
    elsif args[0].is_a? String ; t = args[0].split(".") ; return Time.new(t[0],t[1],t[2],t[3],t[4],t[5])
    end
  end
}
#8#;#3#;#5#;#3#;#1#;#8#;#3#;#5#;#3#;#8#;#5##timer.rb#5#;#6#;#9#;#9#;#4#;#5#;#6#;#7#;#9#;#6#;#4## Timer class definition
# ---
# Undecided on new timer to stick with putting that off while i focus on more important bug fixes and development