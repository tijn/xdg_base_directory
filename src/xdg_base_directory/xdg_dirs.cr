require "./lookup"
require "./xdg_dir"

module XdgBaseDirectory
  # XdgDirs is a helper class to quickly access all the xdg-directories for a certain application.
  #
  # Usage:
  # ```
  # xdg_dirs = XdgDirs.new("my-awesome-app")
  # settings = xdg_dirs.config.read_file("settings.ini")
  # # ...
  # ```
  class XdgDirs
    # define a method to return the specified `XdgDir` for this application.
    macro def_xdg_dir(name, method_name = "")
      def {{method_name}}
        XdgDir.new("#{Lookup.xdg_{{name}}}/#{subdir}")
      end
    end

    @subdir : String

    # This class assumes that all files live in subdirectories of the XDG base dirs.
    def initialize(*subdirs : String)
      @subdir = subdirs.join('/')
      raise "You should use subdirectories" if @subdir.empty?
    end

    # A directory to which user-specific non-essential (cached) data should be written.
    def_xdg_dir cache_home, cache

    # A directory to which user-specific configuration files should be written.
    def_xdg_dir config_home, config

    # A directory to which user-specific data files should be written.
    def_xdg_dir data_home, data

    # A directory in which user-specific runtime files and other file objects should be placed.
    def_xdg_dir runtime_dir, runtime_dir

    # xdg_config_home + xdg_config_dirs as `XdgDir`s
    #
    # The order of base directories denotes their importance; the first directory listed is the most important. When the same information is defined in multiple places the information defined relative to the more important base directory takes precedent. The base directory defined by $XDG_DATA_HOME is considered more important than any of the base directories defined by $XDG_DATA_DIRS. The base directory defined by $XDG_CONFIG_HOME is considered more important than any of the base directories defined by $XDG_CONFIG_DIRS.
    def all_config_dirs
      dir_set(Lookup.xdg_config_home, Lookup.xdg_config_dirs)
    end

    # xdg_data_home + xdg_data_dirs as `XdgDir`s
    #
    # The order of base directories denotes their importance; the first directory listed is the most important. When the same information is defined in multiple places the information defined relative to the more important base directory takes precedent. The base directory defined by $XDG_DATA_HOME is considered more important than any of the base directories defined by $XDG_DATA_DIRS. The base directory defined by $XDG_CONFIG_HOME is considered more important than any of the base directories defined by $XDG_CONFIG_DIRS.
    def all_data_dirs
      dir_set(Lookup.xdg_data_home, Lookup.xdg_data_dirs)
    end

    # Look up configuration files by filename in all config dirs in order of importance.
    #
    # A specification that refers to $XDG_DATA_DIRS or $XDG_CONFIG_DIRS should define what the behaviour must be when a file is located under multiple base directories. It could, for example, define that only the file under the most important base directory should be used or, as another example, it could define rules for merging the information from the different files.
    def config_files(filename)
      select_files_in_group_of_dirs(all_config_dirs, filename)
    end

    # Look up data files by filename in all data dirs in order of importance.
    #
    # A specification that refers to $XDG_DATA_DIRS or $XDG_CONFIG_DIRS should define what the behaviour must be when a file is located under multiple base directories. It could, for example, define that only the file under the most important base directory should be used or, as another example, it could define rules for merging the information from the different files.
    def data_files(filename)
      select_files_in_group_of_dirs(all_data_dirs, filename)
    end

    private def select_files_in_group_of_dirs(dirs, filename)
      dirs.map { |dir| dir.file_path(filename) }.select { |path| File.exists? path }
    end

    private def dir_set(*basedirs)
      basedirs.to_a.flatten.map { |path| XdgDir.new("#{path}/#{@subdir}") }
    end
  end
end
