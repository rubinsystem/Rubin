
if defined?(SYSTEM) != "constant";   ;  end

  
puts "Welcome "+ SYSTEM.host.user.to_s

puts "Launching the Bilbo Database."
SYSTEM.run "bilbodatabase"
puts "Launching the Urlbible."
SYSTEM.run "urlbible"

puts "Launching the webspider."
SYSTEM.run "webspider"

SYSTEM.writelog "Environment ready."
puts "Your envornment it ready."
