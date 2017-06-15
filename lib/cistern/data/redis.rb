# frozen_string_literal: true
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

  class << self
    attr_writer :marshal
  end

  def initialize(options = {}, &block)
    @client  = options[:client] || ::Redis.new
    @default = block
  end

  def clear
    keys = client.keys('*')
    return if keys.empty?

    client.del(*keys)
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
    default.call(client, key) if client.keys(key).empty? && default
  end
end
