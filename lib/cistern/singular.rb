class Cistern::Singular
  extend Cistern::Attributes::ClassMethods
  include Cistern::Attributes::InstanceMethods

  attr_accessor :service

  def inspect
    if Cistern.formatter
      Cistern.formatter.call(self)
    else
      "#<#{self.class}>"
    end
  end

  def initialize(options)
    merge_attributes(options)
    reload
  end

  def reload
    if new_attributes = fetch_attributes
      merge_attributes(new_attributes)
    end
  end

  def fetch_attributes
    raise NotImplementedError
  end
end
