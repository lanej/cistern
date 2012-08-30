require 'spec_helper'

describe "Cistern::Model" do
  context "inspection engine" do
    class Sample < Cistern::Model
      identity :id
      attribute :name
    end

    it "should default to default formatter" do
      Sample.formatter.should == Cistern::Formatter::Default
    end

    it "should use default" do
      Sample.new(id: 1, name: "name").inspect.should match /#<Sample:0x[0-9a-f]+ attributes={id:1,name:\"name\"}/
    end

    it "should use awesome_print" do
      defined?(AwesomePrint).should be_false # don't require if not used
      Sample.formatter= Cistern::Formatter::AwesomePrint

      Sample.new(id: 1, name: "name").inspect.match /(?x-mi:\#<Sample:0x[0-9a-f]+>\ {\n\ \ \ \ \ \ :id\x1B\[0;37m\ =>\ \x1B\[0m\x1B\[1;34m1\x1B\[0m,\n\ \ \ \ :name\x1B\[0;37m\ =>\ \x1B\[0m\x1B\[0;33m"name"\x1B\[0m\n})/
    end

    it "should use formatador" do
      defined?(Formatador).should be_false # don't require if not used
      Sample.formatter= Cistern::Formatter::Formatador

      Sample.new(id: 1, name: "name").inspect.should == "  <Sample\n    id=1,\n    name=\"name\"\n  >"
    end
  end
end
