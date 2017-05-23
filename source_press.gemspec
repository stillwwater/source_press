require_relative "lib/source_press/version"

Gem::Specification.new do |s|
  s.name        = "source_press"
  s.version     = SourcePress::VERSION
  s.executables << "srcpress"
  s.date        = "2017-05-22"
  
  s.summary     = "Compiles multiple source files into a single file"
  s.description = "Easily combine multiple source files into a single file, works on any language as long as .press.yml is configured correctly."
  s.authors     = ["D Stillwwater"]
  s.email       = "stillwwater@gmail.com"
  
  s.files       = ["lib/source_press.rb",
                   "lib/source_press/config.rb",
                   "lib/source_press/message.rb",
                   "lib/source_press/press.rb",
                   "lib/source_press/version.rb"]
  
  s.homepage    = "http://github.com/stillwwater/source_press"
  s.license     = 'WTFPL'
end
