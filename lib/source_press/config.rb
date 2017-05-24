#
# Generates a default config file.
#
module Config
  def self.generate(file)
    abort("Error: #{file} already in directory") if File.exist?(file)

    File.open(file.to_s, "w").puts(default)
    puts "Generated default config file - #{file}"
    exit
  end

  #
  # Returns default config file
  #
  def self.default
    <<~END
      # srcpress configuration file

      # Name + extension of compiled file.
      # Can be left as null/blank
      OutputFile: null

      # When set to true, overrides output file if it's
      # already in the directory.
      OverrideOutput: false

      # Language specific file/library import keywords.
      # ie:
      # Ruby   - 'require', 'require_relative'
      # Python - 'import', 'from'
      # C/C++  - '#include'
      # Can be left as null/blank
      ImportKeywords:
        - null

      # Relative/full path to files in the order
      # in which they should appear in the compiled file.
      #
      # If the order is unimportant, please include a path
      # to the directory/directories containing the files.
      FileOrder:
        - null
    END
  end
end
