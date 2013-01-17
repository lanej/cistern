class Cistern::Collection < Array
  extend Cistern::Attributes::ClassMethods
  include Cistern::Attributes::InstanceMethods

  %w[reject select slice].each do |method|
    define_method(method) do |*args, &block|
      lazy_load unless @loaded
      data = super(*args, &block)
      self.clone.clear.concat(data)
    end
  end

  %w[first last].each do |method|
    define_method(method) do
      lazy_load unless @loaded
      super()
    end
  end

  def self.model(new_model=nil)
    if new_model == nil
      @model
    else
      @model = new_model
    end
  end

  def initialize(attributes = {})
    @loaded = false
    merge_attributes(attributes)
  end

  def create(attributes={})
    self.new(attributes).save
  end

  def get(identity)
    raise NotImplementedError
  end

  def clear
    @loaded = true
    super
  end

  def model
    self.class.instance_variable_get('@model')
  end

  attr_accessor :connection

  def new(attributes = {})
    unless attributes.is_a?(::Hash)
      raise(ArgumentError.new("Initialization parameters must be an attributes hash, got #{attributes.class} #{attributes.inspect}"))
    end
    model.new(
      {
        :collection => self,
        :connection => connection,
      }.merge(attributes)
    )
  end

  def load(objects)
    clear
    for object in objects
      self << new(object)
    end
    self
  end

  def reload
    clear
    lazy_load
    self
  end

  def inspect
    lazy_load unless @loaded
    Cistern.formatter.call(self)
  end

  private

  def lazy_load
    self.all
  end
end
