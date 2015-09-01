class Cistern::Request
  def self.register(service, klass, method)
    service.requests << [method, {class: klass, method: method, new: true}]
  end

  def self.service(klass, options={})
    @service = klass
    method = options[:method] || Cistern::String.underscore(
      Cistern::String.demodulize(self.name)
    )
    Cistern::Request.register(klass, self, method)
  end

  attr_reader :connection

  alias service connection

  def initialize(connection)
    @connection = connection
  end
end
