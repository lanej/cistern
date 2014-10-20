module Cistern::Model
  include Cistern::Attributes::InstanceMethods

  def self.included(klass)
    klass.send(:extend, Cistern::Attributes::ClassMethods)
    klass.send(:include, Cistern::Attributes::InstanceMethods)
  end

  attr_accessor :collection, :service

  def inspect
    if Cistern.formatter
      Cistern.formatter.call(self)
    else
      "#<#{self.class} #{self.identity}"
    end
  end

  def initialize(attributes={})
    merge_attributes(attributes)
  end

  def update(attributes)
    merge_attributes(attributes)
    save
  end

  def save
    raise NotImplementedError
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
       comparison_object.identity == self.identity &&
       !comparison_object.new_record?)
  end

  alias :eql? :==

  def hash
    if self.identity
      [self.class, self.identity].join(":").hash
    else
      super
    end
  end

  def wait_for(timeout = self.service_class.timeout, interval = self.service_class.poll_interval, &block)
    service_class.wait_for(timeout, interval) { reload && block.call(self) }
  end

  def wait_for!(timeout = self.service_class.timeout, interval = self.service_class.poll_interval, &block)
    service_class.wait_for!(timeout, interval) { reload && block.call(self) }
  end

  def service_class
    self.service ? self.service.class : Cistern
  end
end
