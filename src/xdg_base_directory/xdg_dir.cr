module XdgBaseDirectory
  class XdgDir
    def initialize(@path : String)
    end

    def to_s(io)
      io << @path
    end

    def open
      Dir.open(@path)
    end

    def write_file(filename, content, perm = File::DEFAULT_CREATE_MODE, encoding = nil, invalid = nil)
      absolute_path = file_path(filename)
      dir = File.dirname(absolute_path)
      mkdir_p(dir)
      File.write(absolute_path, content, perm, encoding, invalid)
    end

    def read_file(filename)
      absolute_path = file_path(filename)
      File.read(absolute_path)
    end

    def read_lines(filename)
      absolute_path = file_path(filename)
      File.read_lines(absolute_path)
    end

    def file_path(filename)
      "#{@path}/#{filename}"
    end

    def exists?
      Dir.exists?(@path)
    end

    # If, when attempting to write a file, the destination directory is non-existant an attempt should be made to create it with permission 0700. If the destination directory exists already the permissions should not be changed. The application should be prepared to handle the case where the file could not be written, either because the directory was non-existant and could not be created, or for any other reason. In such case it may chose to present an error message to the user.
    def mkdir_p(path)
      Dir.mkdir_p(dir, Oo700)
    end
  end
end
