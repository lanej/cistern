class Cistern::Hash
  def self.slice(hash, *keys)
    keys.each_with_object({}) { |e, a| a[e] = hash[e] if hash.key?(e) }
  end

  def self.except(hash, *keys)
    Cistern::Hash.except!(hash.dup, *keys)
  end

  # Replaces the hash without the given keys.
  def self.except!(hash, *keys)
    keys.each { |key| hash.delete(key) }
    hash
  end

  def self.stringify_keys(object)
    case object
    when Hash
      object.each_with_object({}) { |(k, v), a| a[k.to_s] = stringify_keys(v) }
    when Array
      object.map { |v| stringify_keys(v) }
    else
      object
    end
  end
end
