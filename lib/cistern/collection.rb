class Cistern::Collection
  extend Cistern::Attributes::ClassMethods
  include Cistern::Attributes::InstanceMethods

  include Enumerable

  def each(*args, &block)
    lazy_load
    self.data.each(*args, &block)
    self
  end

  def ==(other)
    lazy_load

    case other
    when Cistern::Collection
      other.lazy_load
      self.data == other.data
    when Array
      self.data == other
    end
  end

  %w[reject select slice].each do |method|
    define_method(method) do |*args, &block|
      lazy_load
      self.clone(self.data.send(method, *args, &block))
    end
  end

  %w[empty? first last size count to_s].each do |method|
    define_method(method) do
      lazy_load
      self.data.send(method)
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

  # @api private
  attr_accessor :data

  alias build initialize

  def initialize(attributes = {})
    @loaded = false
    @data = []
    merge_attributes(attributes)
  end

  def clone(with_data=nil)
    copy = super()
    copy.data = with_data || @data.clone
    copy
  end

  def clear
    @loaded = false
    @data.clear
    self
  end

  def create(attributes={})
    self.new(attributes).save
  end

  def get(identity)
    raise NotImplementedError
  end

  def inspect
    lazy_load
    Cistern.formatter.call(self)
  end

  # @api private
  def lazy_load
    @loaded or self.all
    nil
  end

  def load(objects)
    clear
    for object in objects
      self.data << new(object)
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
