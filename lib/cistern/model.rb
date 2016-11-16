# frozen_string_literal: true
module Cistern::Model
  include Cistern::Attributes::InstanceMethods
  include Cistern::HashSupport

  def self.included(klass)
    klass.send(:extend, Cistern::Attributes::ClassMethods)
    klass.send(:include, Cistern::Attributes::InstanceMethods)
    klass.send(:extend, Cistern::Model::ClassMethods)
    klass.send(:extend, Cistern::Associations)
  end

  def self.cistern_model(cistern, klass, name)
    cistern.const_get(:Collections).module_eval <<-EOS, __FILE__, __LINE__
      def #{name}(attributes={})
    #{klass.name}.new(attributes.merge(cistern: self))
      end
    EOS
  end

  module ClassMethods
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

  attr_accessor :collection, :cistern

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

  def inspect
    Cistern.formatter.call(self)
  end

  def initialize(attributes = {})
    merge_attributes(attributes)
  end

  # Merge #attributes and call {#save}.  Valid and change attributes are available in {#dirty_attributes}
  # @param attributes [Hash]
  def update(attributes)
    stage_attributes(attributes)
    save
  end

  def save
    raise NotImplementedError
  end

  def reload
    requires :identity

    data = collection.get(identity)

    return unless data

    new_attributes = data.attributes
    merge_attributes(new_attributes)
    self
  end

  def ==(other)
    super ||
      (other.is_a?(self.class) &&
       other.identity == identity &&
       !other.new_record?)
  end

  alias eql? ==

  def hash
    if identity
      [self.class, identity].join(':').hash
    else
      super
    end
  end

  def wait_for(timeout = cistern_class.timeout, interval = cistern_class.poll_interval)
    cistern_class.wait_for(timeout, interval) { reload && yield(self) }
  end

  def wait_for!(timeout = cistern_class.timeout, interval = cistern_class.poll_interval)
    cistern_class.wait_for!(timeout, interval) { reload && yield(self) }
  end

  def service_class
    Cistern.deprecation(
      '#service_class is deprecated.  Please use #cistern_class',
      caller[0]
    )
    cistern ? cistern.class : Cistern
  end

  def cistern_class
    cistern ? cistern.class : Cistern
  end
end
