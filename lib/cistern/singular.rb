module Cistern::Singular
  include Cistern::HashSupport

  def self.setup(client, klass, name)
    client.add_resource_method <<-EOS
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
