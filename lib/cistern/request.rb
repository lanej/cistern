module Cistern::Request
  include Cistern::HashSupport

  def self.setup(client, klass, name)
    unless klass.name || klass.cistern_method
      fail ArgumentError, "can't turn anonymous class into a Cistern request"
    end

    client::Mock.module_eval <<-EOS, __FILE__, __LINE__
      def #{name}(*args)
        #{klass}.new(self)._mock(*args)
      end
    EOS

    client::Real.module_eval <<-EOS, __FILE__, __LINE__
      def #{name}(*args)
        #{klass}.new(self)._real(*args)
      end
    EOS
  end

  def self.service_request(*args)
    Cistern.deprecation(
      '#service_request is deprecated.  Please use #cistern_request',
      caller[0]
    )
    cistern_request(*args)
  end

  attr_reader :cistern

  def service
    Cistern.deprecation(
      '#service is deprecated.  Please use #cistern',
      caller[0]
    )
    @cistern
  end

  def initialize(cistern)
    @cistern = cistern
  end

  module ClassMethods
    # @deprecated Use {#cistern_method} instead
    def service_method(name = nil)
      Cistern.deprecation(
        '#service_method is deprecated.  Please use #cistern_method',
        caller[0]
      )
      @_cistern_method ||= name
    end

    def cistern_method(name = nil)
      @_cistern_method ||= name
    end
  end
end
