class Cistern::String
  # stolen from activesupport/lib/active_support/inflector/methods.rb, line 198
  def self.demodulize(path)
    path = path.to_s
    if i = path.rindex('::')
      path[(i+2)..-1]
    else
      path
    end
  end

  # stolen from activesupport/lib/active_support/inflector/methods.rb, line 90
  def self.underscore(camel_cased_word)
    return camel_cased_word unless camel_cased_word =~ /[A-Z-]|::/
    word = camel_cased_word.to_s.gsub(/::/, '/')
    #word.gsub!(/(?:(?<=([A-Za-z\d]))|\b)(#{inflections.acronym_regex})(?=\b|[^a-z])/) { "#{$1 && '_'}#{$2.downcase}" }
    word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    word.tr!("-", "_")
    word.downcase!
    word
  end
end
