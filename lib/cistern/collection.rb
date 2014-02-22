class Cistern::Collection
  extend Cistern::Attributes::ClassMethods
  include Cistern::Attributes::InstanceMethods

  BLACKLISTED_ARRAY_METHODS = [
    :compact!, :flatten!, :reject!, :reverse!, :rotate!, :map!,
    :shuffle!, :slice!, :sort!, :sort_by!, :delete_if,
    :keep_if, :pop, :shift, :delete_at, :compact
  ].to_set # :nodoc:

  attr_accessor :records, :loaded, :connection

  def self.model(new_model=nil)
    if new_model == nil
      @model
    else
      @model = new_model
    end
  end

  alias build initialize

  def initialize(attributes = {})
    merge_attributes(attributes)
  end

  def all(identity)
    raise NotImplementedError
  end

  def create(attributes={})
    self.new(attributes).save
  end

  def get(identity)
    raise NotImplementedError
  end

  def clear
    self.loaded = false
    records && records.clear
  end

  def inspect
    if Cistern.formatter
      Cistern.formatter.call(self)
    else super
    end
  end

  # @api private
  def load_records
    self.all unless self.loaded
  end

  # Should be called within #all to load records into the collection
  # @param [Array<Hash>] objects list of record attributes to be loaded
  # @return self
  def load(objects)
    self.records = (objects || []).map { |object| new(object) }
    self.loaded = true
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
    load_records
    self
  end

  def to_a
    load_records
    self.records || []
  end

  def respond_to?(method, include_private = false)
    super || array_delegable?(method)
  end

  def ==(comparison_object)
    comparison_object.equal?(self) ||
      (comparison_object.is_a?(self.class) &&
       comparison_object.to_a == self.to_a)
  end

  protected

  def array_delegable?(method)
    Array.method_defined?(method) && !BLACKLISTED_ARRAY_METHODS.include?(method)
  end

  def method_missing(method, *args, &block)
    if array_delegable?(method)
      to_a.public_send(method, *args, &block)
    else
      super
    end
  end
end
