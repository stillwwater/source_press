require_relative "message"
require "yaml"

module Press
  #
  # Defines settings required by the compiler.
  # Settings are loaded from a .press.yml config file.
  #
  # Each user setting is evaluated and errors are handled
  # beforehand so the compiler only receives valid input
  #
  class Settings
    attr_accessor :output,
                  :ovr_output,
                  :ext,
                  :file_order,
                  :import_kwords

    def initialize(file)
      self.file_order = []
      paths = load(file)
      error_check(paths)

      # No output file provided
      self.output = "out" << ext if output.nil? || output.empty?
    end

    private

    #
    # Load .press.yml settings file
    # Params:
    # +file+:: Path to .press.yml
    #
    def load(file)
      help = "Use `srcpress gen-config` to generate a template config file"
      Message::Error.no_file("config", file, help) unless File.exist?(file)

      press_yml          = YAML.load_file(file)
      self.output        = press_yml["OutputFile"]
      self.ovr_output    = press_yml["OverrideOutput"]
      self.import_kwords = press_yml["ImportKeywords"]

      press_yml["FileOrder"]
    end

    #
    # Run error checks on each file
    # self.file_order can only contain valid file paths
    # Params:
    # +paths+:: Array of file/dir paths provided in .press.yml
    #
    def error_check(paths)
      e = check_files(paths)
      Message::Error.no_files(e) unless e.empty?

      e = check_extnames
      Message::Warning.ext_warn(e, ext) unless e.empty?
    end

    #
    # Check if selected paths are valid files or directories
    # If path is directory get all files in the directory
    # Add invalid files to `errors`
    # Params:
    # +paths+:: Array of file/dir paths provided in .press.yml
    #
    def check_files(paths)
      Message::Error.error_puts("No files to load") if paths.nil?

      errors = []
      paths.each do |f|
        f = "nil" if f.nil?

        if Dir.exist?(f)
          # Get files in directory
          Dir["#{f}/*"].each { |x| file_order << x unless Dir.exist?(f) }
          next
        end

        if File.exist?(f)
          file_order << File.absolute_path(f)
          next
        end

        # Invalid path
        errors << File.basename(f)
      end

      errors
    end

    #
    # Check if the current file_order contains more than
    # one type of extension, raises a warning if true.
    #
    def check_extnames
      errors = []
      file_order.each do |f|
        self.ext = File.extname(f) if ext.nil?
        next if File.extname(f) == ext

        # Multiple extensions
        errors << File.basename(f)
      end

      errors
    end
  end

  #
  # Reads settings.file_order line by line, evaluates whether
  # the line is an "import" statement and appends the result
  # to a temporary file.
  # A header containing all of the necessary imports is then
  # compiled with the contents in the tmp file.
  #
  # The compiler should never load a file into memory in its
  # entirety, the file should instead be read line by line
  # as to save memory.
  # This process is certainly slower, however, it is a good
  # compromise, especially when loading large files.
  #
  class Compiler
    attr_accessor :settings,
                  :check_import,
                  :head,
                  :removed,
                  :ln_ending,
                  :tmp_files,
                  :silent

    def initialize(settings, silent = false)
      self.settings     = settings
      self.silent       = silent
      self.check_import = true
      self.head         = []
      self.removed      = []
      self.tmp_files    = []

      import_kwords_warning
    end

    #
    # Runs compiler
    #
    def run
      start = Time.now

      # Parse lines removing import statements
      count = parse_files

      out_name = settings.output
      # Delete
      (settings.ovr_output && File.exist?(out_name)) && File.delete(out_name)

      # Combine head with output and export compiled file
      final_out = make_file(out_name)
      compile_output(final_out)
      final_out.close

      silent || puts(compile_info(count, final_out, (Time.now - start) * 1000))
    end

    private

    #
    # Cycles through files in settings.file_order, creates a
    # temporary file for appending and calls parse_lines
    # to evaluate each line in the current file.
    # Params:
    # +out+:: Temporary file
    #
    def parse_files
      ln_count = 0

      settings.file_order.each do |f|
        out = make_file("tmp.press")

        ln_count += parse_lines(f, out)

        out.close
        tmp_files << out
      end

      ln_count
    end

    #
    # Reads lines in file_order and appends them to a
    # temporary file unless the line is an import statement
    # as defined in `settings.import_kwords`
    # Params:
    # +input+:: File to read
    # +out+:: Output File for appending
    #
    def parse_lines(input, out)
      lines = 0

      File.readlines(input).each do |ln|
        lines += 1

        # Get line ending
        self.ln_ending ||= ln if ln.chomp.empty?

        # Append line to out unless it is an import
        out.puts(ln) unless line_import?(ln)
      end
      lines
    rescue SystemCallError => e
      Message::Warning.warning_puts("Could not load #{input} - #{e}")
      return 0
    end

    #
    # Checks if current line is an import statement
    # by checking it agains `settings.import_kwords`
    # Params:
    # +ln+:: Current lone
    #
    def line_import?(ln)
      return false unless check_import

      ln = ln.strip
      words = ln.split(" ")
      is_kword = settings.import_kwords.include?(words[0])
      return false unless is_kword

      head << ln unless head.include?(ln) || local_import?(ln, words)
      true
    end

    #
    # Checks if import statement is importing a file
    # that will be compiled.
    # Params:
    # +ln+:: Current line
    # +words+:: Line split by spaces
    #
    def local_import?(ln, words)
      tmp = nil

      settings.file_order.each do |f|
        words[1..-1].each do |w|
          w.delete!("'\"")
          # Remove . from relative path
          while w[0] == "." do w = w[1..-1] end

          tmp = ln if f.include?(w.downcase)
        end
      end

      removed << tmp unless tmp.nil?
      !tmp.nil?
    end

    #
    # Copies lines from a file to another, removing
    # any leading new lines.
    # Params:
    # +input+:: Read from
    # +out+:: Append to
    #
    def copy_lines(input, out)
      last = ""
      leading = nil

      File.readlines(input).each do |ln|
        # Check for leading blank lines
        leading ||= ln unless ln.chomp.empty?
        out.puts ln unless leading.nil?

        last = ln
      end

      last
    end

    #
    # Combines head with tmp_file
    # Params:
    # +tmp_file+:: Name of temporary file
    # +out+:: Output File object
    #
    def compile_output(out)
      head.each { |ln| out.puts ln }

      # Add new line between import statements and output
      out.puts ln_ending

      tmp_files.each do |tmp|
        last = copy_lines(tmp, out)

        out.puts ln_ending unless last.chomp.empty?
        File.delete(tmp)
      end
    end

    #
    # Creates and returns a file for appending
    # Params:
    # +fname+:: New file name
    #
    def make_file(fname)
      ext = File.extname(fname)

      i = 1
      while File.exist?(fname)
        # In case a file with the same name already exists
        fname = File.basename(fname, ext)
        fname = fname.sub(/\d+$/, "") << i.to_s << ext

        i += 1
      end

      File.open(fname, "a")
    end

    #
    # Displays a warning if no "import" keywords were
    # defined in the .press.yml config file and disables
    # checking for imports when reading files.
    #
    def import_kwords_warning
      kwords = settings.import_kwords
      return unless kwords.nil? || kwords.none?

      msg = "ImportKeywords left empty in config file"
      Message::Warning.warning_puts(msg)

      self.check_import = false
    end

    #
    # Displays info after the compiling is complete
    # Params:
    # +elapsed+:: Time elapsed during run in milliseconds
    #
    def compile_info(lines, out, elapsed)
      elapsed_s = format("%.2fms", elapsed)

      tmp = "\nProcess completed (#{settings.file_order.size} files, " \
            "#{lines} lines) in #{elapsed_s} " \
            "- output in #{out.path}\n"
      return tmp if removed.empty?

      rm_ln = "\nRemoved lines:\n"
      removed.each { |ln| rm_ln << " - #{ln}\n" }

      rm_ln << "\nThey are believed to be local " \
             "#{settings.import_kwords[0]} statements.\n" \
             "Please verify that is the case.\n"
      rm_ln << tmp
    end
  end
end
