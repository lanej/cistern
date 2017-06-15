# frozen_string_literal: true
require 'timeout'

module Cistern::WaitFor
  def timeout
    @timeout || Cistern.timeout
  end

  def timeout=(timeout)
    @timeout = timeout
  end

  def poll_interval
    @poll_interval || Cistern.poll_interval
  end

  def poll_interval=(poll_interval)
    @poll_interval = poll_interval
  end

  def timeout_error=(timeout_error)
    @timeout_error = timeout_error
  end

  def timeout_error
    @timeout_error || const_defined?(:Timeout) && const_get(:Timeout) || ::Timeout::Error
  end

  def wait_for(timeout = self.timeout, interval = poll_interval, &_block)
    duration = 0
    start    = Time.now

    until yield || duration > timeout
      sleep(interval.to_f)
      duration = Time.now - start
    end

    duration > timeout ? false : duration
  end

  def wait_for!(timeout = self.timeout, interval = poll_interval, &block)
    wait_for(timeout, interval, &block) || raise(timeout_error, "wait_for(#{timeout}) exceeded")
  end
end
