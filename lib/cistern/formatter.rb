# frozen_string_literal: true

module Cistern::Formatter
  autoload :AwesomePrint, 'cistern/formatter/awesome_print'
  autoload :Formatador,   'cistern/formatter/formatador'

  def self.default
    if defined?(::AwesomePrint)
      Cistern::Formatter::AwesomePrint
    elsif defined?(::Formatador)
      Cistern::Formatter::Formatador
    else
      Cistern::Formatter::Default
    end
  end
end

require 'cistern/formatter/default'
