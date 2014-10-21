module Cistern::Request
  def self.service_request(service, klass)
    request = klass.request_name || Cistern::String.camelize(Cistern::String.demodulize(klass.name))

    service::Mock.module_eval <<-EOS, __FILE__, __LINE__
      def #{request}(*args)
        #{klass}.new(self).mock(*args)
      end
    EOS

    service::Real.module_eval <<-EOS, __FILE__, __LINE__
      def #{request}(*args)
        #{klass}.new(self).real(*args)
      end
    EOS
  end

  attr_reader :service

  def initialize(service)
    @service = service
  end

  module ClassMethods
    def request_name
    end
  end
end
