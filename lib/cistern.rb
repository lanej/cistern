require 'cistern/version'

require 'time'
require 'set'

module Cistern

  Error   = Class.new(StandardError)
  Timeout = Class.new(Error)

  require 'cistern/hash'
  require 'cistern/mock'
  require 'cistern/wait_for'
  require 'cistern/attributes'
  require 'cistern/collection'
  require 'cistern/model'
  require 'cistern/service'
  require 'cistern/singular'
  require 'cistern/data'
  require 'cistern/data/hash'
  require 'cistern/data/redis'

  extend WaitFor

  require 'cistern/formatter'

  def self.formatter=(formatter); @formatter = formatter; end

  def self.formatter
    @formatter ||= Cistern::Formatter.default
  end
end

Cistern.timeout       = 180 # 3 minutes
Cistern.poll_interval = 15  # 15 seconds
