# frozen_string_literal: true
require 'awesome_print'

module Cistern::Formatter::AwesomePrint
  def self.call(model)
    model.ai
  end
end

module AwesomePrint::Cistern
  def self.included(base)
    base.send :alias_method, :cast_without_cistern, :cast
    base.send :alias_method, :cast, :cast_with_cistern
  end

  def cast_with_cistern(object, type)
    cast = cast_without_cistern(object, type)
    if object.is_a?(Cistern::Model)
      cast = :cistern_model
    elsif object.is_a?(Cistern::Singular)
      cast = :cistern_model
    elsif object.is_a?(Cistern::Collection)
      cast = :cistern_collection
    end
    cast
  end

  # Format Cistern::Model
  #------------------------------------------------------------------------------
  def awesome_cistern_model(object)
    data = object.attributes.keys.sort.each_with_object({}) { |e, a| a[e] = object.public_send(e) }
    "#{object} " + awesome_hash(data)
  end

  # Format Cistern::Model
  #------------------------------------------------------------------------------
  def awesome_cistern_collection(object)
    "#{object.class.name} " + awesome_hash(attributes: object.attributes, records: object.to_a)
  end
end

AwesomePrint::Formatter.send(:include, AwesomePrint::Cistern)
