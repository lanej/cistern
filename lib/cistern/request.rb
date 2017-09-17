# frozen_string_literal: true

module Cistern::Request
  include Cistern::HashSupport

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

  def self.cistern_request(cistern, klass, name)
    unless klass.name || klass.cistern_method
      fail ArgumentError, "can't turn anonymous class into a Cistern request"
    end

    method = <<-EOS
      def #{name}(*args)
        #{klass}.new(self).call(*args)
      end
    EOS


    cistern::Mock.module_eval method, __FILE__, __LINE__
    cistern::Real.module_eval method, __FILE__, __LINE__
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

  def call(*args)
    dispatch(*args)
  end

  def real(*)
    raise NotImplementedError
  end

  def mock(*)
    raise NotImplementedError
  end

  protected

  # @fixme remove _{mock,real} methods and call {mock,real} directly before 3.0 release.
  def dispatch(*args)
    to = cistern.mocking? ? :mock : :real

    legacy_method = :"_#{to}"

    if respond_to?(legacy_method)
      Cistern.deprecation(
        '#_mock is deprecated.  Please use #mock and/or #call. See https://github.com/lanej/cistern#request-dispatch',
        caller[0]
      )

      public_send(legacy_method, *args)
    else
      public_send(to, *args)
    end
  end
end
