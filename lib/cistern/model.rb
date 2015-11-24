module Cistern::Model
  include Cistern::Attributes::InstanceMethods

  def self.included(klass)
    klass.send(:extend, Cistern::Attributes::ClassMethods)
    klass.send(:include, Cistern::Attributes::InstanceMethods)
    klass.send(:extend, Cistern::Model::ClassMethods)
  end

  def self.service_model(service, klass, name)
    service.const_get(:Collections).module_eval <<-EOS, __FILE__, __LINE__
      def #{name}(attributes={})
        #{klass.name}.new(attributes.merge(service: self))
      end
    EOS
  end

  module ClassMethods
    def service_method(name = nil)
      @_service_method ||= name
    end
  end

  attr_accessor :collection, :service

  def inspect
    Cistern.formatter.call(self)
  end

  def initialize(attributes = {})
    merge_attributes(attributes)
  end

  def update(attributes)
    merge_attributes(attributes)
    save
  end

  def save
    fail NotImplementedError
  end

  def reload
    requires :identity

    if data = collection.get(identity)
      new_attributes = data.attributes
      merge_attributes(new_attributes)
      self
    end
  end

  def ==(comparison_object)
    super ||
      (comparison_object.is_a?(self.class) &&
       comparison_object.identity == identity &&
       !comparison_object.new_record?)
  end

  alias_method :eql?, :==

  def hash
    if identity
      [self.class, identity].join(':').hash
    else
      super
    end
  end

  def wait_for(timeout = service_class.timeout, interval = service_class.poll_interval, &block)
    service_class.wait_for(timeout, interval) { reload && block.call(self) }
  end

  def wait_for!(timeout = service_class.timeout, interval = service_class.poll_interval, &block)
    service_class.wait_for!(timeout, interval) { reload && block.call(self) }
  end

  def service_class
    service ? service.class : Cistern
  end
end
