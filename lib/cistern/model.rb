class Cistern::Model
  extend Cistern::Attributes::ClassMethods
  include Cistern::Attributes::InstanceMethods

  attr_accessor :collection, :connection

  def initialize(attributes={})
    merge_attributes(attributes)
  end

  def inspect
    Thread.current[:formatador] ||= Formatador.new
    data = "#{Thread.current[:formatador].indentation}<#{self.class.name}"
    Thread.current[:formatador].indent do
      unless self.class.attributes.empty?
        data << "\n#{Thread.current[:formatador].indentation}"
        data << self.class.attributes.map {|attribute| "#{attribute}=#{send(attribute).inspect}"}.join(",\n#{Thread.current[:formatador].indentation}")
      end
    end
    data << "\n#{Thread.current[:formatador].indentation}>"
    data
  end


  def save
    raise NotImplementedError
  end

  def reload
    requires :identity

    data = collection.get(identity)

    new_attributes = data.attributes
    merge_attributes(new_attributes)
    self
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
