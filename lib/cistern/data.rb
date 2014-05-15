module Cistern::Data
  def self.extended(klass)
    klass.send(:extend, ClassMethods)
    klass.send(:include, InstanceMethods)
  end

  def self.backends
    @backends ||= {}
  end

  module ClassMethods
    def data
      @data ||= Cistern::Data.backends[storage].new(@options || {}) { |d,k| d[k] = [] }
    end

    def reset!
      clear!
      @data = nil
    end

    def clear!
      self.data.clear
    end

    def store_in(storage, options)
      @storage = storage
      @options = options
      @data = nil
    end

    def storage
      @storage ||= :hash
    end
  end

  module InstanceMethods
    def data
      self.class.data
    end

    def reset!
      self.class.reset!
    end
  end
end
