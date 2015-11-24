module Cistern::Formatter::Default
  class << self
    def call(object)
      case object
      when Cistern::Collection
        format_collection(object)
      when Cistern::Model
        format_model(object)
      else
        object.to_s
      end
    end

    def format_model(model)
      "#{model} #{model.attributes.inspect}"
    end

    def format_collection(collection)
      "#{collection} #{collection.attributes.inspect} records=[#{collection.records.map { |m| format_model(m) }.join(', ')}]"
    end
  end
end
