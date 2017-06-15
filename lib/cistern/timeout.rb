# frozen_string_literal: true
module Cistern::WaitFor
  def self.wait_for(timeout = Cistern.timeout, interval = Cistern.poll_interval, &_block)
    duration = 0
    start    = Time.now

    until yield || duration > timeout
      sleep(interval.to_f)
      duration = Time.now - start
    end

    if duration > timeout
      false
    else
      { duration: duration }
    end
  end

  def self.wait_for!(*_arg)
    wait_for
  end
end
