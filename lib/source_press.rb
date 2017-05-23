require_relative "source_press/version"
require_relative "source_press/press"
require_relative "source_press/config"

#
# Runs compiler
#
def start_press(config_file, is_silent)
  settings = Press::Settings.new(config_file)
  Press::Compiler.new(settings, is_silent).run
end

#
# Main entry point
#
def main(args)
  is_silent = false
  config    = ".press.yml"

  unless args.empty?
    abort(SourcePress::VERSION) if args[0] == "-v"
    is_silent = args.include?("--silent")

    m = args[0].match(/config=(.*)/)
    config = m[1].strip unless m.nil?

    Config.generate(config) if args[0].strip == "gen-config"
  end
  start_press(config, is_silent)
end
