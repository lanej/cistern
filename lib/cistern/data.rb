# frozen_string_literal: true

module Cistern::Data
  def self.extended(klass)
    klass.send(:extend, ClassMethods)
    klass.send(:include, InstanceMethods)
  end

  def self.backends
    @backends ||= {}
  end

  def self.backend(*args, &block)
    engine, options = args

    Cistern::Data.backends[engine].new(options || {}, &block)
  end

  module ClassMethods
    def data
      @data ||= Cistern::Data.backend(*storage) { |d, k| d[k] = [] }
    end

    def reset!
      clear!
      @data = nil
    end

    def clear!
      data.clear
    end

    def store_in(*args, **kwargs)
      @storage = *args
      @data    = nil
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
