module Cistern::Singular
  include Cistern::HashSupport

  def self.cistern_singular(cistern, klass, name)
    cistern.const_get(:Collections).module_eval <<-EOS, __FILE__, __LINE__
      def #{name}(attributes={})
    #{klass.name}.new(attributes.merge(cistern: self))
      end
    EOS
  end

  def self.included(klass)
    klass.send(:extend, Cistern::Attributes::ClassMethods)
    klass.send(:include, Cistern::Attributes::InstanceMethods)
    klass.send(:extend, Cistern::Model::ClassMethods)
  end

  attr_accessor :cistern

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

  def initialize(options)
    merge_attributes(options)
  end

  def fetch(*args)
    reload(*args)
    self
  end

  def reload
    raise NotImplementedError
  end
end
