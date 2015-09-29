require 'cistern/version'

# stdlib
require 'time'

module Cistern

  Error   = Class.new(StandardError)
  Timeout = Class.new(Error)

  require 'cistern/hash'
  require 'cistern/string'
  require 'cistern/mock'
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

  def self.formatter=(formatter); @formatter = formatter; end

  def self.formatter
    @formatter ||= Cistern::Formatter.default
  end

  def self.deprecation_warnings?
    @deprecation_warnings.nil? ? true : !!@deprecation_warnings
  end

  def self.deprecation_warnings=(status)
    @deprecation_warnings = status
  end

  def self.deprecation(message, source=caller[1])
    if deprecation_warnings?
      STDERR.puts("#{message}. (#{source})")
    end
  end
end

Cistern.timeout       = 180 # 3 minutes
Cistern.poll_interval = 15  # 15 seconds
