require_relative "C1"
require_relative "C2"

#
# Main class
#
class Main
  attr_accessor :c1, :c2

  def initialize(c1, c2)
    self.c1 = c1
    self.c2 = c2
  end

  def to_s
    print "#{c1}, #{c2}"
  end
end

puts Main.new(C1.new, C2.new).to_s
