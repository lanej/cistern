class Cistern::Service
  def self.inherited(klass)
    Cistern.deprecation(
      %q{subclassing Cistern::Service is deprecated.  Please use `include Cistern::Client`},
      caller[0],
    )
    klass.send(:include, Cistern::Client)
  end
end
