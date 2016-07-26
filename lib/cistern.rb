require 'cistern/version'

# stdlib
require 'time'
# also required by 'rspec'. do not remove
require 'set'

module Cistern
  Error   = Class.new(StandardError)
  Timeout = Class.new(Error)

  require 'cistern/hash'
  require 'cistern/hash_support'
  require 'cistern/string'
  require 'cistern/mock'
  require 'cistern/associations'
  require 'cistern/wait_for'
  require 'cistern/attributes'
  require 'cistern/collection'
  require 'cistern/model'
  require 'cistern/service'
  require 'cistern/client'
  require 'cistern/singular'
  require 'cistern/request'
  require 'cistern/data'
  require 'cistern/data/hash'
  require 'cistern/data/redis'

  extend WaitFor

  require 'cistern/formatter'

  def self.formatter=(formatter)
    @formatter = formatter
  end

  def self.formatter
    @formatter ||= Cistern::Formatter.default
  end

  def self.deprecation_warnings?
    @deprecation_warnings.nil? ? true : !!@deprecation_warnings
  end

  def self.deprecation_warnings=(status)
    @deprecation_warnings = status
  end

  def self.deprecation(message, source = caller[1])
    STDERR.puts("#{message}. (#{source})") if deprecation_warnings?
  end
end

Cistern.timeout       = 180 # 3 minutes
Cistern.poll_interval = 15  # 15 seconds
