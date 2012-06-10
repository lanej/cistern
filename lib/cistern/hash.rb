class Cistern::Hash
  def self.slice(hash, *keys)
    {}.tap do |sliced|
      keys.each{|k| sliced[k]= hash[k] if hash.key?(k)}
    end
  end
end
