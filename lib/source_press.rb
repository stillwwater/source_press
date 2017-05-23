require_relative "source_press/version"
require_relative "source_press/press"
require_relative "source_press/config"

#
# Main entry point
#
def main(args)
  config = ".press.yml"

  unless args.empty?
    abort(SourcePress::VERSION) if args[0] == "-v"

    m = args[0].match(/config=(.*)/)
    config = m[1].strip unless m.nil?

    Config.generate(config) if args[0].strip == "gen-config"
  end

  settings = Press::Settings.new(config)
  Press::Compiler.new(settings).run
end
