module Cistern::Singular
  attr_accessor :service

  def self.included(klass)
    klass.send(:extend, Cistern::Attributes::ClassMethods)
    klass.send(:include, Cistern::Attributes::InstanceMethods)
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

    if new_attributes
      merge_attributes(new_attributes)
    end
  end

  def fetch_attributes
    raise NotImplementedError
  end
end
