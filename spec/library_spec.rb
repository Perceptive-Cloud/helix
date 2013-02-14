require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::Library do

  let(:klass)             { Helix::Library }
  subject                 { klass }
  its(:guid_name)         { should eq('library_id') }
  its(:resource_label_sym)    { should be(:library)   }
  its(:plural_resource_label) { should eq('libraries') }
  [:find, :create, :all, :find_all, :where].each do |crud_call|
    it { should respond_to(crud_call) }
  end

  describe ".known_attributes" do
    let(:meth)            { :known_attributes }
    let(:expected_attrs)  { [ :player_profile, 
                              :ingest_profile, 
                              :secure_stream_callback_url, 
                              :hooks_attributes] }
    it "should equal expected_attrs" do
      expect(klass.send(meth)).to eq(expected_attrs)
    end
  end

  describe "Constants"

  describe "an instance" do
    let(:obj)            { klass.new({'library_id' => 'some_library_id'}) }
    subject              { obj }
    its(:resource_label_sym) { should be(:library) }
    [:destroy, :update].each do |crud_call|
      it { should respond_to(crud_call) }
    end
  end
end