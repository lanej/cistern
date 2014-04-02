require 'timeout'

module Cistern
  module WaitFor
    DEFAULT_TIMEOUT       = 180 # 3 minutes
    DEFAULT_POLL_INTERVAL = 10  # 10 seconds

    # These are the actual stored global versions
    class <<self
      attr_writer :timeout
      def timeout
        @timeout ||= Cistern::WaitFor::DEFAULT_TIMEOUT
      end

      attr_writer :poll_interval
      def poll_interval
        @poll_interval ||= Cistern::WaitFor::DEFAULT_POLL_INTERVAL
      end

      attr_writer :timeout_error
      def timeout_error
        @timeout_error ||= self.const_defined?(:Timeout) && self.const_get(:Timeout) || ::Timeout::Error
      end
    end

    # Call out to the global versions
    def timeout; Cistern::WaitFor.timeout; end
    def timeout=(t); Cistern::WaitFor.timeout = t; end
    def poll_interval; Cistern::WaitFor.poll_interval; end
    def poll_interval=(p); Cistern::WaitFor.poll_interval = p; end
    def timeout_error; Cistern::WaitFor.timeout_error; end
    def timeout_error=(e); Cistern::WaitFor.timeout_error = e; end

    def wait_for(timeout = self.timeout, interval = self.poll_interval, &block)
      duration = 0
      start    = Time.now

      until yield || duration > timeout
        sleep(interval.to_f)
        duration = Time.now - start
      end

      duration > timeout ? false : duration
    end

    def wait_for!(timeout = self.timeout, interval = self.poll_interval, &block)
      wait_for(timeout, interval, &block) || raise(timeout_error, "wait_for(#{timeout}) exceeded")
    end
  end
end
