# frozen_string_literal: true
class Cistern::Service
  def self.inherited(klass)
    Cistern.deprecation(
      'subclassing Cistern::Service is deprecated.  Please use `include Cistern::Client`',
      caller[0]
    )
    klass.send(:include, Cistern::Client)
  end
end
