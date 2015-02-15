class Cistern::Hash
  def self.slice(hash, *keys)
    {}.tap do |sliced|
      keys.each{ |k| sliced[k] = hash[k] if hash.key?(k) }
    end
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
      object.inject({}){|r,(k,v)| r.merge(k.to_s => stringify_keys(v))}
    when Array
      object.map{|v| stringify_keys(v) }
    else
      object
    end
  end
end
