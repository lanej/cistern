class Cistern::Model
  extend Cistern::Attributes::ClassMethods
  include Cistern::Attributes::InstanceMethods

  attr_accessor :collection, :connection

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

  def service
    self.connection ? self.connection.class : Cistern
  end

  def wait_for(timeout = self.service.timeout, interval = self.service.poll_interval, &block)
    service.wait_for(timeout, interval) { reload && block.call(self) }
  end

  def wait_for!(timeout = self.service.timeout, interval = self.service.poll_interval, &block)
    service.wait_for!(timeout, interval) { reload && block.call(self) }
  end
end
