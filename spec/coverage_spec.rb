# frozen_string_literal: true

require 'spec_helper'

describe 'coverage', :coverage do
  subject {
    class Sample::Coverage < Sample::Model
      identity :id

      attribute :used, type: :string
      attribute :unused, type: :string
    end

    Sample::Coverage
  }

  let!(:model) { subject.new(used: 'foo', unused: 'bar') }

  before(:each) do
    subject.attributes[:used][:coverage_hits] = 0
    expect(model.used).to eq('foo') # once
    expect(model.used).to eq('foo') # twice
  end

  it 'should store the file path where the attribute was defined' do
    expect(subject.attributes[:used][:coverage_file]).to eq(__FILE__)
    expect(subject.attributes[:unused][:coverage_file]).to eq(__FILE__)
  end

  it 'should store the line number where the attribute was defined' do
    src_lines = File.read(__FILE__).lines

    expect(src_lines[subject.attributes[:used][:coverage_line] - 1]).to match(/attribute :used/)
    expect(src_lines[subject.attributes[:unused][:coverage_line] - 1]).to match(/attribute :unused/)
  end

  it "should store how many times an attribute's reader is called" do
    expect(subject.attributes[:used][:coverage_hits]).to eq(2)
    expect(subject.attributes[:unused][:coverage_hits]).to eq(1)
  end
end
