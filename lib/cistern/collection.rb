# frozen_string_literal: true
module Cistern::Collection
  include Cistern::HashSupport

  BLACKLISTED_ARRAY_METHODS = [
    :compact!, :flatten!, :reject!, :reverse!, :rotate!, :map!,
    :shuffle!, :slice!, :sort!, :sort_by!, :delete_if,
    :keep_if, :pop, :shift, :delete_at, :compact,
  ].to_set # :nodoc:

  def self.cistern_collection(cistern, klass, name)
    cistern.const_get(:Collections).module_eval <<-EOS, __FILE__, __LINE__
      def #{name}(attributes={})
        #{klass.name}.new(attributes.merge(cistern: self))
      end
    EOS
  end

  attr_accessor :records, :loaded, :cistern

  def service=(service)
    Cistern.deprecation(
      '#service= is deprecated.  Please use #cistern=',
      caller[0]
    )
    @cistern = service
  end

  def service
    Cistern.deprecation(
      '#service is deprecated.  Please use #cistern',
      caller[0]
    )
    @cistern
  end

  module ClassMethods
    def model(new_model = nil)
      @_model ||= new_model
    end

    # @deprecated Use {#cistern_method} instead
    def service_method(name = nil)
      Cistern.deprecation(
        '#service_method is deprecated.  Please use #cistern_method',
        caller[0]
      )
      @_cistern_method ||= name
    end

    def cistern_method(name = nil)
      @_cistern_method ||= name
    end
  end

  alias build initialize

  def initialize(attributes = {})
    @loaded = false
    merge_attributes(attributes)
  end

  def all(_ = {})
    raise NotImplementedError
  end

  def create(attributes = {})
    new(attributes).save
  end

  def get(_identity)
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
    all unless loaded
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
    self.class.model
  end

  def new(attributes = {})
    unless attributes.is_a?(::Hash)
      raise ArgumentError, "Initialization parameters must be an attributes hash, got #{attributes.class} #{attributes.inspect}"
    end
    model.new(
      {
        collection: self,
        cistern: cistern,
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
    records || []
  end

  def respond_to?(method, include_private = false)
    super || array_delegable?(method)
  end

  def ==(other)
    other.equal?(self) ||
      (other.is_a?(self.class) &&
       other.to_a == to_a)
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

  def respond_to_missing?(method, *)
    array_delegable?(method) || super
  end
end
