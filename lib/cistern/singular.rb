module Cistern::Singular
  def self.service_singular(service, klass, name)
    service.const_get(:Collections).module_eval <<-EOS, __FILE__, __LINE__
      def #{name}(attributes={})
        #{klass.name}.new(attributes.merge(service: self))
      end
    EOS
  end

  def self.included(klass)
    klass.send(:extend, Cistern::Attributes::ClassMethods)
    klass.send(:include, Cistern::Attributes::InstanceMethods)
    klass.send(:extend, Cistern::Model::ClassMethods)
  end

  attr_accessor :service

  def inspect
    Cistern.formatter.call(self)
  end

  def initialize(options)
    merge_attributes(options)
    reload
  end

  def reload
    new_attributes = fetch_attributes

    merge_attributes(new_attributes) if new_attributes
  end

  def fetch_attributes
    fail NotImplementedError
  end
end
