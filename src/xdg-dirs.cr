require "./xdg_base_directory"

dirs = XdgBaseDirectory::XdgDirs.new(ARGV.first)

puts "config:"
dirs.all_config_dirs.each do |dir|
  puts "#{dir} #{dir.exists? ? "*" : ""}"
end

puts
puts "data:"
dirs.all_data_dirs.each do |dir|
  puts "#{dir} #{dir.exists? ? "*" : ""}"
end
