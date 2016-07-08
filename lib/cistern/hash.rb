class Cistern::Hash
  # @example
  #   Cistern::Hash.slice({ :a => 1, :b => 2 }, :a) #=> { :a => 1 }
  # @return [Hash] copy of {#hash} containing only {#keys}
  def self.slice(hash, *keys)
    keys.each_with_object({}) { |e, a| a[e] = hash[e] if hash.key?(e) }
  end

  # @example
  #   Cistern::Hash.except({ :a => 1, :b => 2 }, :a) #=> { :b => 2 }
  # @return [Hash] copy of {#hash} containing all keys except {#keys}
  def self.except(hash, *keys)
    Cistern::Hash.except!(hash.dup, *keys)
  end

  # Remove all keys not specified in {#keys} from {#hash} in place
  #
  # @example
  #   Cistern::Hash.except({ :a => 1, :b => 2 }, :a) #=> { :b => 2 }
  # @return [Hash] {#hash}
  # @see {Cistern::Hash#except}
  def self.except!(hash, *keys)
    keys.each { |key| hash.delete(key) }
    hash
  end

  # Copy {#hash} and convert all keys to strings recursively.
  #
  # @example
  #   Cistern::Hash.stringify_keys(:a => 1, :b => 2) #=> { 'a' => 1, 'b' => 2 }
  # @return [Hash] {#hash} with string keys
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
