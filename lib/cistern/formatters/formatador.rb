require 'formatador'

module Cistern::Formatter::Formatador
  def self.call(model)
    Thread.current[:formatador] ||= Formatador.new
    data = "#{Thread.current[:formatador].indentation}<#{model.class.name}"
    Thread.current[:formatador].indent do
      unless model.class.attributes.empty?
        data << "\n#{Thread.current[:formatador].indentation}"
        data << model.class.attributes.map {|attribute| "#{attribute}=#{model.send(attribute).inspect}"}.join(",\n#{Thread.current[:formatador].indentation}")
      end
    end
    data << "\n#{Thread.current[:formatador].indentation}>"
    data
  end
end
