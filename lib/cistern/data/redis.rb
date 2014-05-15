class Cistern::Data::Redis
  Cistern::Data.backends[:redis] = self

  def self.marshal
    @marshal ||= begin
                   require 'multi_json'
                   MultiJson
                 rescue LoadError
                   require 'json'
                   ::JSON
                 end
  end

  def self.marshal=(marshal)
    @marshal = marshal
  end

  def initialize(options={}, &block)
    @client  = options[:client] || ::Redis.new
    @default = block
  end

  def clear
    unless (keys = client.keys("*")).empty?
      client.del(*keys)
    end
  end

  def store(key, value, *args)
    assign_default(key)

    client.set(key, Cistern::Data::Redis.marshal.dump(value), *args)
  end

  alias []= store

  def fetch(key, *args)
    assign_default(key)

    Cistern::Data::Redis.marshal.load(client.get(key, *args))
  end

  alias [] fetch

  protected

  attr_reader :client, :default

  def assign_default(key)
    if client.keys(key).empty? && default
      default.call(client, key)
    end
  end
end
