module Cistern::Singular
  include Cistern::Model

  def self.cistern_singular(cistern, klass, name)
    cistern.const_get(:Collections).module_eval <<-EOS, __FILE__, __LINE__
      def #{name}(attributes={})
        #{klass.name}.new(attributes.merge(cistern: self))
      end
    EOS
  end

  def self.included(klass)
    super

    klass.send(:extend, Cistern::Attributes::ClassMethods)
    klass.send(:include, Cistern::Attributes::InstanceMethods)
    klass.send(:extend, Cistern::Model::ClassMethods)
    klass.send(:extend, Cistern::Associations)
  end

  def collection
    self
  end

  def get
    raise NotImplementedError
  end

  def reload
    get
    self
  end

  alias load reload
end
