module Cistern::Request
  def self.service_request(service, klass, name)
    service::Mock.module_eval <<-EOS, __FILE__, __LINE__
      def #{name}(*args)
        #{klass}.new(self)._mock(*args)
      end
    EOS

    service::Real.module_eval <<-EOS, __FILE__, __LINE__
      def #{name}(*args)
        #{klass}.new(self)._real(*args)
      end
    EOS
  end

  attr_reader :service

  def initialize(service)
    @service = service
  end

  module ClassMethods
    def request_name(name=nil)
      @_request_name ||= name
    end
  end
end
