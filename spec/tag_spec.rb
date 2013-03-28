require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::Tag do

  let(:klass) { Helix::Tag }
  subject     { klass }
  its(:resource_label_sym)    { should be(:tag)   }
  its(:plural_resource_label) { should eq('tags') }
  it { should_not respond_to(:find) }
  it { should_not respond_to(:create) }
  it { should respond_to(:all)}
  it { should respond_to(:find_all)}

  describe "Constants"

  describe "an instance" do
    let(:obj) { klass.new({}) }
    subject   { obj }
    its(:resource_label_sym)  { should be(:tag) }
    it { should_not respond_to(:destroy) }
    it { should_not respond_to(:update) }
  end
end
