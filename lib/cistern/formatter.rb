module Cistern::Formatter
  autoload :AwesomePrint, 'cistern/formatter/awesome_print'
  autoload :Default, 'cistern/formatter/default'
  autoload :Formatador, 'cistern/formatter/formatador'

  def self.default
    if defined?(::AwesomePrint)
      Cistern::Formatter::AwesomePrint
    elsif defined?(::Formatador)
      Cistern::Formatter::Formatador
    end
  end
end
