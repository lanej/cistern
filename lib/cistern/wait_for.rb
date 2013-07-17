require 'timeout'

module Cistern
  module WaitFor
    DEFAULT_TIMEOUT       = 3 * 60 # 3 minutes
    DEFAULT_POLL_INTERVAL = 10 # seconds

    def timeout; @timeout || DEFAULT_TIMEOUT; end
    def timeout=(timeout); @timeout = timeout; end
    def poll_interval; @poll_interval || DEFAULT_POLL_INTERVAL; end
    def poll_interval=(poll_interval); @poll_interval = poll_interval; end
    def timeout_error=(timeout_error); @timeout_error = timeout_error; end
    def timeout_error; @timeout_error || self.const_defined?(:Timeout) && self.const_get(:Timeout) || ::Timeout::Error; end

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
