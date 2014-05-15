class Cistern::Data::Hash
  Cistern::Data.backends[:hash] = self

  def initialize(options={}, &default)
    @hash    = Hash.new
    @default = default
  end

  def clear
    hash.clear
  end

  def store(key, *args)
    assign_default(key)

    hash.store(key, *args)
  end

  alias []= store

  def fetch(key, *args)
    assign_default(key)

    hash.fetch(key, *args)
  end

  alias [] fetch

  protected

  attr_reader :hash, :default

  def assign_default(key)
    if !hash.key?(key) && default
      default.call(hash, key)
    end
  end
end
