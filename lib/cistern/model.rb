class Cistern::Model
  extend Cistern::Attributes::ClassMethods
  include Cistern::Attributes::InstanceMethods

  attr_accessor :collection, :connection

  def inspect
    Cistern.formatter.call(self)
  end

  def initialize(attributes={})
    merge_attributes(attributes)
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
    comparison_object.equal?(self) ||
      (comparison_object.is_a?(self.class) && 
       comparison_object.identity == self.identity && 
       !comparison_object.new_record?)
  end

  def wait_for(timeout=Cistern.timeout, interval=1, &block)
    reload
    retries = 3
    Cistern.wait_for(timeout, interval) do
      if reload
        retries = 3
      elsif retries > 0
        retries -= 1
        sleep(1)
      elsif retries == 0
        raise Cistern::Error.new("Reload failed, #{self.class} #{self.identity} went away.") # FIXME: pretty much assumes you are calling #ready?
      end
      instance_eval(&block)
    end
  end
end
