module Cistern
  module WaitFor
    def self.wait_for(timeout = Cistern.timeout, interval = Cistern.poll_interval, &block)
      duration = 0
      start    = Time.now

      until yield || duration > timeout
        sleep(interval.to_f)
        duration = Time.now - start
      end

      if duration > timeout
        false
      else
        { :duration => duration }
      end
    end

    def self.wait_for!(*arg)
      wait_for
    end
  end
end
