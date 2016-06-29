require 'spec_helper'

describe 'coverage', :coverage do
  class CoverageSpec < Sample::Model
    identity :id

    attribute :used, type: :string
    attribute :unused, type: :string
  end

  let!(:obj) { CoverageSpec.new(used: 'foo', unused: 'bar') }

  before(:each) do
    CoverageSpec.attributes[:used][:coverage_hits] = 0
    expect(obj.used).to eq('foo') # once
    expect(obj.used).to eq('foo') # twice
  end

  it 'should store the file path where the attribute was defined' do
    expect(CoverageSpec.attributes[:used][:coverage_file]).to eq(__FILE__)
    expect(CoverageSpec.attributes[:unused][:coverage_file]).to eq(__FILE__)
  end

  it 'should store the line number where the attribute was defined' do
    src_lines = File.read(__FILE__).lines

    expect(src_lines[CoverageSpec.attributes[:used][:coverage_line] - 1]).to match(/attribute :used/)
    expect(src_lines[CoverageSpec.attributes[:unused][:coverage_line] - 1]).to match(/attribute :unused/)
  end

  it "should store how many times an attribute's reader is called" do
    expect(CoverageSpec.attributes[:used][:coverage_hits]).to eq(2)
    expect(CoverageSpec.attributes[:unused][:coverage_hits]).to eq(3)
  end
end
