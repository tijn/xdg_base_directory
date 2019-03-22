module XdgBaseDirectory
  # look up base directories
  module Lookup
    DEFAULT_DATA_DIRS   = "/usr/local/share/:/usr/share/"
    DEFAULT_CONFIG_DIRS = "/etc/xdg"

    # A single base directory relative to which user-specific non-essential (cached) data should be written.
    def self.xdg_cache_home
      # $XDG_CACHE_HOME defines the base directory relative to which user specific non-essential data files should be stored. If $XDG_CACHE_HOME is either not set or empty, a default equal to $HOME/.cache should be used.
      dir_from_env("XDG_CACHE_HOME") { "#{home}/.cache" }
    end

    # A set of preference ordered base directories relative to which configuration files should be searched.
    def self.xdg_config_dirs
      # $XDG_CONFIG_DIRS defines the preference-ordered set of base directories to search for configuration files in addition to the $XDG_CONFIG_HOME base directory. The directories in $XDG_CONFIG_DIRS should be seperated with a colon ':'.
      # If $XDG_CONFIG_DIRS is either not set or empty, a value equal to /etc/xdg should be used.
      dirs_from_env("XDG_CONFIG_DIRS", DEFAULT_CONFIG_DIRS)
    end

    # A single base directory relative to which user-specific configuration files should be written.
    def self.xdg_config_home
      # $XDG_CONFIG_HOME defines the base directory relative to which user specific configuration files should be stored. If $XDG_CONFIG_HOME is either not set or empty, a default equal to $HOME/.config should be used.
      dir_from_env("XDG_CONFIG_HOME") { "#{home}/.config" }
    end

    # A set of preference ordered base directories relative to which data files should be searched.
    def self.xdg_data_dirs
      # $XDG_DATA_DIRS defines the preference-ordered set of base directories to search for data files in addition to the $XDG_DATA_HOME base directory. The directories in $XDG_DATA_DIRS should be seperated with a colon ':'.
      # If $XDG_DATA_DIRS is either not set or empty, a value equal to /usr/local/share/:/usr/share/ should be used.
      dirs_from_env("XDG_DATA_DIRS", DEFAULT_DATA_DIRS)
    end

    # A set of preference ordered base directories relative to which data files should be searched.
    def self.xdg_data_home
      # $XDG_DATA_HOME defines the base directory relative to which user specific data files should be stored. If $XDG_DATA_HOME is either not set or empty, a default equal to $HOME/.local/share should be used.
      dir_from_env("XDG_DATA_HOME") { "#{home}/.local/share" }
    end

    # A single base directory relative to which user-specific runtime files and other file objects should be placed.
    def self.xdg_runtime_dir
      # $XDG_RUNTIME_DIR defines the base directory relative to which user-specific non-essential runtime files and other file objects (such as sockets, named pipes, ...) should be stored. The directory MUST be owned by the user, and he MUST be the only one having read and write access to it. Its Unix access mode MUST be 0700.
      # If $XDG_RUNTIME_DIR is not set applications should fall back to a replacement directory with similar capabilities and print a warning message. Applications should use this directory for communication and synchronization purposes and should not place larger files in it, since it might reside in runtime memory and cannot necessarily be swapped out to disk.
      dir = dir_from_env("XDG_RUNTIME_DIR") do
        fallback = "/tmp/#{ENV["USERNAME"]}"
        Dir.mkdir_p(fallback, 0o700)
        STDERR.puts "warning: $XDG_RUNTIME_DIR is not set; using #{fallback} instead."
        fallback
      end
      info = File.info(dir)
      raise "runtime dir must be a directory" unless info.directory?
      raise "runtime dir must be owned by user" unless info.owner == user_id
      raise "user must be the only one with read and write access to runtime dir" unless info.permissions == File::Permissions::OwnerAll
      dir
    end

    # The user's home directory
    def self.home
      ENV.fetch("HOME")
    end

    private def self.user_id
      # FIXME: there must be a better way to do this but there is no Process::uid as far as I can see
      `id -u`.to_i
    end

    # Fetch XDG-directory variable from `ENV`.
    # If the value has not been set or if it is invalid the return value of the block will be used instead.
    #
    # - If [...] **is either not set or empty**, a default equal to [...] should be used.
    # - All paths set in these environment variables must be absolute. If an implementation encounters a relative path in any of these variables it should consider the path invalid and ignore it.
    private def self.dir_from_env(name)
      value = ENV[name]?.to_s
      if value.empty? || relative_path?(value)
        return yield
      else
        value
      end
    end

    # Fetch XDG-directory variable from `ENV`.
    # If the value has not been set or if it is invalid the default will be used.
    private def self.dir_from_env(name, default)
      fetch_xdg_dir(name) { default }
    end

    # Fetch list of XDG-directory paths from ENV variable.
    # If the value has not been set or if it is invalid the default will be used.
    private def self.dirs_from_env(name, default)
      value = ENV[name]?
      dirs = valid_dirs(value.to_s)
      if dirs.empty?
        valid_dirs(default)
      else
        dirs
      end
    end

    # All paths set in these environment variables must be absolute. If an implementation encounters a relative path in any of these variables it should consider the path invalid and ignore it.
    private def self.valid_dirs(variable)
      variable.split(':').reject { |path| relative_path?(path) }
    end

    private def self.absolute_path?(path)
      path.starts_with?('/')
    end

    private def self.relative_path?(path)
      !absolute_path?(path)
    end
  end
end
