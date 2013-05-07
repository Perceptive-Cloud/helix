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


  describe ".get_data_sets" do
    let(:meth)         { :get_data_sets }
    let(:raw_response) { {"tags" => :expected} }
    let(:mock_config)  { mock(Helix::Config, build_url: :the_url, get_response: raw_response) }
    let(:opts)         { {} }
    before(:each)      { klass.stub(:config) { mock_config }}
    bu_opts          = {content_type: :xml, resource_label: "tags"}
    it "should receive build_url(#{bu_opts})" do
      mock_config.should_receive(:build_url).with(bu_opts) { :the_url }
      klass.send(meth, opts)
    end
    it "should call mock_config.get_response()" do
      mock_config.should_receive(:get_response).with(:the_url, {sig_type: :view}.merge(opts)) { raw_response }
      klass.send(meth, opts)
    end
    it "should return raw_response[:tags]" do
      expect(klass.send(meth, opts)).to eq(:expected)
    end
  end

  describe "Constants"

  describe "an instance" do
    let(:obj) { klass.new({}) }
    subject   { obj }
    its(:resource_label_sym)  { should be(:tag) }
    it { should_not respond_to(:destroy) }
    it { should_not respond_to(:update) }
  end
end
