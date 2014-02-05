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

  %w[first last size count inspect].each do |method|
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

  attr_accessor :connection

  alias build initialize

  def initialize(attributes = {})
    @loaded = false
    merge_attributes(attributes)
  end

  def clear
    @loaded = false
    super
  end

  def create(attributes={})
    self.new(attributes).save
  end

  def get(identity)
    raise NotImplementedError
  end

  def inspect
    lazy_load unless @loaded
    Cistern.formatter.call(self)
  end

  # @api private
  def lazy_load
    self.all
  end

  def load(objects)
    clear
    for object in objects
      self << new(object)
    end
    @loaded = true
    self
  end

  def model
    self.class.instance_variable_get('@model')
  end

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

  def reload
    clear
    lazy_load
    self
  end
end
