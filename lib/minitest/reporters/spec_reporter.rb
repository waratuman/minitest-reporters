require 'ansi/code'

module Minitest
  module Reporters
    # Turn-like reporter that reads like a spec.
    #
    # Based upon TwP's turn (MIT License) and paydro's monkey-patch.
    #
    # @see https://github.com/TwP/turn turn
    # @see https://gist.github.com/356945 paydro's monkey-patch
    class SpecReporter < BaseReporter
      include ANSI::Code
      include RelativePosition

      def start
        super
        puts 'Started'
        puts
      end

      def report
        super
        puts('Finished in %.5fs' % total_time)
        print('%d tests, %d assertions, ' % [count, assertions])
        color = failures.zero? && errors.zero? ? :green : :red
        print(send(color) { '%d failures, %d errors, ' } % [failures, errors])
        print(yellow { '%d skips' } % skips)
        puts
      end

      def record(test)
        super

        return if options[:only_failures] && test.passed?

        if options[:only_failures] && !@current_suite_printed
          puts @current_suite
          @current_suite_printed = true
        end

        print pad_test(test.name)
        print_colored_status(test)
        print(" (%.2fs)" % test.time)
        puts
        if !test.skipped? && test.failure
          print_info(test.failure)
          puts
        end
      end

      protected

      def before_suite(suite)
        if !options[:only_failures]
          puts suite
        else
          @current_suite = suite
          @current_suite_printed = false
        end
      end

      def after_suite(suite)
        if !options[:only_failures]
          puts
        else
          @current_suite = nil
        end
      end
    end
  end
end
