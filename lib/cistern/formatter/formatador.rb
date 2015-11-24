require 'formatador'

module Cistern::Formatter::Formatador
  def self.call(model)
    case model
    when Cistern::Collection then collection_inspect(model)
    when Cistern::Model then model_inspect(model)
    when Cistern::Singular then model_inspect(model)
    else model.inspect
    end
  end

  def self.model_inspect(model)
    Thread.current[:formatador] ||= Formatador.new
    data = "#{Thread.current[:formatador].indentation}<#{model.class.name}"
    Thread.current[:formatador].indent do
      unless model.class.attributes.empty?
        data << "\n#{Thread.current[:formatador].indentation}"
        data << model.class.attributes.map { |attribute, _| "#{attribute}=#{model.send(attribute).inspect}" }.join(",\n#{Thread.current[:formatador].indentation}")
      end
    end
    data << "\n#{Thread.current[:formatador].indentation}>"
    data
  end

  def self.collection_inspect(collection)
    Thread.current[:formatador] ||= Formatador.new
    data = "#{Thread.current[:formatador].indentation}<#{collection.class.name}\n"
    Thread.current[:formatador].indent do
      unless collection.class.attributes.empty?
        data << "#{Thread.current[:formatador].indentation}"
        data << collection.class.attributes.map { |attribute| "#{attribute}=#{send(attribute).inspect}" }.join(",\n#{Thread.current[:formatador].indentation}")
        data << "\n"
      end
      data << "#{Thread.current[:formatador].indentation}["
      unless collection.empty?
        data << "\n"
        Thread.current[:formatador].indent do
          data << collection.map(&:inspect).join(",\n")
          data << "\n"
        end
        data << Thread.current[:formatador].indentation
      end
      data << "]\n"
    end
    data << "#{Thread.current[:formatador].indentation}>"
    data
  end

  def table(attributes = nil)
    Formatador.display_table(map(&:attributes), attributes)
  end
end
