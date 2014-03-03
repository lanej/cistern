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

  extend WaitFor

  autoload :Formatter, 'cistern/formatter'

  def self.formatter=(formatter); @formatter = formatter; end

  def self.formatter
    @formatter ||= Cistern::Formatter.default
  end
end
