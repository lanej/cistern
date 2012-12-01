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

  def inspect
    Thread.current[:formatador] ||= Formatador.new
    data = "#{Thread.current[:formatador].indentation}<#{self.class.name}\n"
    Thread.current[:formatador].indent do
      unless self.class.attributes.empty?
        data << "#{Thread.current[:formatador].indentation}"
        data << self.class.attributes.map {|attribute| "#{attribute}=#{send(attribute).inspect}"}.join(",\n#{Thread.current[:formatador].indentation}")
        data << "\n"
      end
      data << "#{Thread.current[:formatador].indentation}["
      unless self.empty?
        data << "\n"
        Thread.current[:formatador].indent do
          data << self.map {|member| member.inspect}.join(",\n")
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
    Formatador.display_table(self.map {|instance| instance.attributes}, attributes)
  end
end
