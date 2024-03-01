require "./xdg_base_directory"

if ARGV.empty?
  puts "Usage: xdg-dirs [PROGRAM-NAME]"
  puts
  puts "Outputs the xdg directories to be used for a given program."
  exit
end

def dir_description(dir)
  "#{dir} #{dir.exists? ? "*" : ""}"
end

dirs = XdgBaseDirectory.app_directories(ARGV.first)

puts "config:"
dirs.all_config_dirs.each do |dir|
  puts dir_description(dir)
end

puts
puts "data:"
dirs.all_data_dirs.each do |dir|
  puts dir_description(dir)
end

puts
puts "cache:"
puts dir_description(dirs.cache)

puts
puts "runtime_dir:"
begin
  puts dir_description(dirs.runtime_dir)
rescue error
  puts error
end

puts
puts "state:"
puts dir_description(dirs.state)
