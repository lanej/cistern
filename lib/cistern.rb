require "cistern/version"

module Cistern
  Error = Class.new(StandardError)

  require "cistern/hash"
  require 'cistern/mock'
  require 'cistern/wait_for'
  require "cistern/attributes"
  require "cistern/collection"
  require "cistern/model"
  require "cistern/service"

  def self.timeout=(timeout)
    @timeout= timeout
  end

  def self.timeout
    @timeout || 0
  end
end
