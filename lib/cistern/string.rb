# frozen_string_literal: true

class Cistern::String
  def self.camelize(string)
    string.gsub(/[A-Z]+/) { |w| "_#{w.downcase}" }.gsub(/^_/, '')
  end

  # File activesupport/lib/active_support/inflector/methods.rb, line 90
  def self.underscore(camel_cased_word)
    word = camel_cased_word.to_s.gsub('::', '/')
    # word.gsub!(/(?:([A-Za-z\d])|^)(#{inflections.acronym_regex})(?=\b|[^a-z])/) { "#{$1}#{$1 && '_'}#{$2.downcase}" }
    word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
    word.tr!('-', '_')
    word.downcase!
    word
  end

  # File activesupport/lib/active_support/inflector/methods.rb, line 168
  def self.demodulize(path)
    path = path.to_s
    if i = path.rindex('::')
      path[(i + 2)..-1]
    else
      path
    end
  end

  # @todo omg so bad
  def self.pluralize(string)
    "#{string}s"
  end
end
