#
# Displays messages to the user
#
module Message
  #
  # Outputs errors to the command line
  #
  class Error
    def self.no_files(errors = nil)
      msg = "Could not load file(s):"
      error_puts(msg, errors)
    end

    def self.no_file(type, file, extra = "")
      msg = "Could not load #{type} file, #{file}"
      error_puts(msg << "\n       " << extra)
    end

    # Print error message
    def self.error_puts(message, errors = nil)
      puts "\nError: #{message}"
      errors&.each { |e| puts " - " << e }

      exit # Fatal error, exit program
    end
  end

  #
  # Outputs warnings to the command line
  #
  class Warning
    def self.ext_warn(warnings, ext)
      msg = "Trying to compile multiple extensions " \
            "(expected #{ext}), found:"
      warning_puts(msg, warnings)
    end

    #
    # Print warning
    #
    def self.warning_puts(message, warnings = nil)
      puts "\nWarning: #{message}"
      warnings&.each { |e| puts " - " << e }
    end
  end
end
