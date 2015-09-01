class Cistern::Request
  def self.register(service, klass, method)
    service.requests << [method, {class: klass, method: method, new: true}]
  end

  def self.service(klass, options={})
    @service = klass
    @service_method = options[:method] || Cistern::String.underscore(
      Cistern::String.demodulize(self.name)
    )
    Cistern::Request.register(klass, self, @service_method)
  end

  def self.service_method
    @service_method
  end

  attr_reader :connection

  alias service connection

  def initialize(connection)
    @connection = connection
  end

  def _real(*args, &block)
    real(*args, &block)
  end

  def _mock(*args, &block)
    mock(*args, &block)
  end

  def real(*args, &block)
    raise NotImplementedError
  end

  def mock(*args, &block)
    Cistern::Mock.not_implemented(self.class.service_method)
  end
end
