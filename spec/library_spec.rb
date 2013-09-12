require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::Library do

  let(:klass) { Helix::Library }
  subject     { klass }

  mods = [ Helix::Base, Helix::RESTful ]
  mods.each { |mod| its(:ancestors) { should include(mod) } }
  its(:ancestors) { should_not include(Helix::Media) }

  its(:guid_name)             { should eq('name')       }
  its(:resource_label_sym)    { should be(:library)     }
  its(:plural_resource_label) { should eq('libraries')  }
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

  describe ".find" do
    let(:meth)  { :find }
    subject     { klass.method(meth) }
    its(:arity) { should eq(-2) }
    context "when given just a nickname" do
=begin
      it "should call super(nickname, {content_type: :xml})" do
        Helix::Base.should_not_receive(:load)
        Helix::RESTful.should_not_receive(:find)
        expect(klass.send(meth, :a_nickname)).to be :blah
      end
=end
    end
    context "when given a nickname and opts" do
=begin
      it "should call super(nickname, opts.merge(content_type: :xml))" do
        Helix::Base.should_not_receive(:load)
        Helix::RESTful.should_not_receive(:find)
        expect(klass.send(meth, :a_nickname, {k: :v})).to be :blah
      end
=end
    end
  end

  describe "an instance" do
    let(:obj)            { klass.new({'library_id' => 'some_library_id'}) }
    subject              { obj }
    its(:resource_label_sym) { should be(:library) }
    [:destroy, :update].each do |crud_call|
      it { should respond_to(crud_call) }
    end
  end

end
