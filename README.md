# xdg_base_directory

An implementation of the XDG Base Directory specs in Crystal-lang

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  xdg_base_directory:
    github: tijn/xdg_base_directory
```

## Usage

```crystal
require "xdg_base_directory"

xdg_dirs = XdgBaseDirectory.app_directories("my-awesome-app")

settings = xdg_dirs.config.read_file("settings.ini")
xdg_dirs.config.write_file("settings.ini.backup", setttings)

# open the cache directory
xdg_dirs.cache.to_dir # returns a Dir instance

# open the runtime directory
xdg_dirs.runtime_dir.to_dir # returns a Dir instance
```

## Contributing

1. Fork it ( https://github.com/tijn/xdg_base_directory/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [tijn](https://github.com/tijn) Tijn Schuurmans - creator, maintainer
