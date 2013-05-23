require 'cistern/version'
require 'time'

module Cistern
  Error = Class.new(StandardError)

  require 'cistern/hash'
  require 'cistern/mock'
  require 'cistern/wait_for'
  require 'cistern/attributes'
  require 'cistern/collection'
  require 'cistern/model'
  require 'cistern/service'

  autoload :Formatter, 'cistern/formatter'

  def self.timeout=(timeout); @timeout= timeout; end
  def self.timeout; @timeout || 0; end
  def self.formatter=(formatter); @formatter = formatter; end

  def self.formatter
    @formatter ||= if defined?(AwesomePrint)
                     Cistern::Formatter::AwesomePrint
                   elsif defined?(Formatador)
                     Cistern::Formatter::Formatador
                   else Cistern::Formatter::Default
                   end
  end
end
