class Cistern::Hash
  def self.slice(hash, *keys)
    {}.tap do |sliced|
      keys.each{ |k| sliced[k] = hash[k] if hash.key?(k) }
    end
  end

  def self.except(hash, *keys)
    hash.dup.except!(*keys)
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
