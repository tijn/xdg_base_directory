require "./xdg_base_directory/*"

module XdgBaseDirectory
  # https://specifications.freedesktop.org/basedir-spec/latest/
  # https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html
  def self.app_directories(app_name : String)
    XdgBaseDirectory::XdgDirs.new(app_name)
  end
end
