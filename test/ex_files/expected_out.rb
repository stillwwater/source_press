require "yaml"

#
# Example class 1
#
class C1
  def initialize
    # Body ommited
  end

  def method_1
    # body omitted
  end

  def method_2
    # body omitted
  end

  def method_3
    # body omitted
  end
end

#
# Example class 2
#
class C2
  def initialize
    # Body ommited
  end

  def method_1
    # body omitted
  end

  def method_2
    # body omitted
  end

  def method_3
    # body omitted
  end
end

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

