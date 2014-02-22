require 'spec_helper'

describe "#inspect" do
  class Inspector < Cistern::Model
    identity :id
    attribute :name
  end
  class Inspectors < Cistern::Collection
    model Inspector

    def all
      self.load([{id: 1, name: "2"},{id: 3, name: "4"}])
    end
  end

  describe "Cistern::Model" do
    it "should use awesome_print" do
      Cistern.formatter = Cistern::Formatter::AwesomePrint

      Inspector.new(id: 1, name: "name").inspect.match /(?x-mi:\#<Inspector:0x[0-9a-f]+>\ {\n\ \ \ \ \ \ :id\x1B\[0;37m\ =>\ \x1B\[0m\x1B\[1;34m1\x1B\[0m,\n\ \ \ \ :name\x1B\[0;37m\ =>\ \x1B\[0m\x1B\[0;33m"name"\x1B\[0m\n})/
    end

    it "should use formatador" do
      Cistern.formatter = Cistern::Formatter::Formatador

      Inspector.new(id: 1, name: "name").inspect.should == %q{  <Inspector
    id=1,
    name="name"
  >}
    end
  end

  describe "Cistern::Collection" do
    it "should use formatador" do
      Cistern.formatter = Cistern::Formatter::Formatador
      Inspectors.new.all.inspect.should == %q{  <Inspectors
    [
      <Inspector
        id=1,
        name="2"
      >,
      <Inspector
        id=3,
        name="4"
      >
    ]
  >}
    end

    it "should use awesome_print" do
      Cistern.formatter = Cistern::Formatter::AwesomePrint
      Inspectors.new.all.inspect.should match(/Inspectors\s+\[.*\]$/m) # close enough
    end
  end
end
