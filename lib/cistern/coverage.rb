# frozen_string_literal: true
module Cistern::Coverage
  unless Kernel.respond_to? :caller_locations
    abort <<-ABORT
Cannot enable Cistern coverage reporting

Your ruby version ruby is: #{begin
                               RUBY_VERSION
                             rescue
                               'unknown'
                             end}
`Kernel` does not have the required method `caller_locations`

Try a newer ruby (should be > 2.0)
    ABORT
  end

  # returns the first caller_locations entry before entries in `file`
  def self.find_caller_before(file)
    enum = caller_locations.each

    # seek to the first entry from within `file`
    while (call = enum.next)
      break if call.path.end_with? file
    end

    # seek to the first entry thats not within `file`
    while (call = enum.next)
      break unless call.path.end_with? file
    end

    # the call location that called in to `file`
    call
  end
end
