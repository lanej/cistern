class Cistern::String
  def self.camelize(string)
    string.gsub(/[A-Z]+/) { |w| "_#{w.downcase}" }.gsub(/^_/, "")
  end
end
