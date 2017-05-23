require "test/unit"
require_relative "../lib/source_press/press"

module Test
  #
  # Tests and runs a benchmark on Press::Compiler
  #
  class CompilerTest < Test::Unit::TestCase
    attr_accessor :delays

    def setup
      self.delays = []
      @settings   = Press::Settings.new(".press.yml")
    end

    #
    # Assert that the settings have been loaded correctly
    # and match the content in .press.yml
    #
    def test_settings
      assert(@settings.output == "out.rb")
      assert(@settings.ext == ".rb")
      assert(@settings.import_kwords == ["require", "require_relative"])
      assert(!@settings.file_order.nil?)
    end

    #
    # Assert that the ouput from the compiler matches
    # the content in expected_out.rb
    #
    def test_compiler
      2000.times.each do |i|
        (i % 40).zero? && print(".")

        start = Time.now

        # Run compiler
        @compiler = Press::Compiler.new(@settings, true).run

        delays << Time.now - start

        assert(File.read("out.rb") == File.read("ex_files/expected_out.rb"))
        File.delete("out.rb")
      end
      puts "\n" << benchmark_results
    end

    private

    def benchmark_results
      delays.map! { |x| x * 1000 }

      # min, max, avg
      min, max = delays.minmax
      mean = delays.inject(0.0) { |sum, x| sum + x } / delays.size

      <<~END

        ----------------------------
        Compiler Benchmark:

        Average: #{mean}ms

        Fastest: #{min}ms
        Slowest: #{max}ms
        ----------------------------

      END
    end
  end
end
