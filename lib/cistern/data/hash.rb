# frozen_string_literal: true

class Cistern::Data::Hash
  Cistern::Data.backends[:hash] = self

  def initialize(_options = {}, &default)
    @hash    = {}
    @default = default
  end

  def clear
    hash.clear
  end

  def store(key, *args)
    assign_default(key)

    hash.store(key, *args)
  end

  alias_method :[]=, :store

  def fetch(key, *args)
    assign_default(key)

    hash.fetch(key, *args)
  end

  alias_method :[], :fetch

  protected

  attr_reader :hash, :default

  def assign_default(key)
    default.call(hash, key) if !hash.key?(key) && default
  end
end
