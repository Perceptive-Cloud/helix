require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::Base do

  def set_stubs(obj)
    obj.instance_variable_set(:@attributes, {})
    [:plural_media_type, :guid, :signature].each_with_index do |call, index|
      obj.stub(call) { index.to_s }
    end
  end

  let(:klass) { Helix::Base }

  subject { klass }

  describe ".find" do
    let(:meth) { :find }
    subject { klass.method(meth) }
    its(:arity) { should eq(1) }
    context "when given a guid" do
      subject { klass }
      let(:guid) { :a_guid }
      let(:mock_instance) { mock(Object, :load => nil) }
      it "should instantiate with attributes: { guid_name => the_guid }" do
        klass.should_receive(:guid_name) { :the_guid_name }
        klass.should_receive(:new).with({attributes: { the_guid_name: guid }}) { mock_instance }
        klass.send(meth, guid)
      end
      it "should load" do
        klass.stub(:guid_name) { :the_guid_name }
        klass.stub(:new) { mock_instance }
        mock_instance.should_receive(:load) { :expected }
        expect(klass.send(meth, guid)).to eq(:expected)
      end
    end
  end

#TODO: Possible cleanup.
  describe ".get_response" do
    let(:meth) { :get_response }
    subject { klass.method(meth) }
    its(:arity) { should eq(-2) }
    context "when given a url and options" do
      subject { klass }
      let(:string) { String.new }
      let(:opts) { Hash.new }
      let(:params) { { params: { signature: string } } }
      let(:returned_json) { '{"key": "val"}' }
      let(:json_parsed)   { { "key" => "val" } }
      it "should call RestClient.get and return a hash from parsed JSON" do
        klass.stub(:signature) { string }
        RestClient.should_receive(:get).with(string, params) { returned_json }
        expect(klass.send(meth, string, opts)).to eq(json_parsed)
      end
    end
  end

  describe ".signature" do
  end

 describe ".find_all" do
    let(:meth) { :find_all }
    subject { klass.method(meth) }
    its(:arity) { should eq(1) }
    context "when called with multiple { attribute: :value }" do
      let(:opts) { Hash.new }
      let(:attr_value) { { attribute: :value } }
      let(:attrs_hash) { { attributes: attr_value } } 
      let(:obj_count) { 2 }
      before(:each) do 
        klass.stub(:get_response) do 
          { klasses: (1..obj_count).map { attr_value } }
        end
        klass.stub(:plural_media_type) { :klasses }
      end
      it "should call new twice with attribute hashes" do
        klass.should_receive(:new).exactly(obj_count).times
        klass.send(meth, opts)
      end
      subject { klass.send(meth, opts).first }
      it { should be_an_instance_of(klass) }

      #Specific matching not working. 
      #subject { klass.send(meth, opts) }
      #it { should eq((1..2).map { klass.new(attrs_hash) }) }

    end
  end

  describe "Constants"

  # attr_accessor attributes

  describe "an instance" do
    let(:obj) { klass.new({}) }

    describe "#guid" do
      let(:meth) { :guid }
      it "should return @attributes[guid_name]" do
        mock_attributes = mock(Object)
        obj.instance_variable_set(:@attributes, mock_attributes)
        obj.should_receive(:guid_name) { :the_guid_name }
        mock_attributes.should_receive(:[]).with(:the_guid_name) { :expected }
        expect(obj.send(meth)).to eq(:expected)
      end
    end

    describe "#method_missing" do
      let(:meth) { :method_missing }
      subject { obj.method(meth) }
      its(:arity) { should eq(1) }
      context "when given method_sym" do
        let(:method_sym) { :method_sym }
        it "should return @attributes[method_sym.to_s]" do
          mock_attributes = mock(Object)
          obj.instance_variable_set(:@attributes, mock_attributes)
          mock_attributes.should_receive(:[]).with(method_sym.to_s) { :expected }
          expect(obj.send(meth, method_sym)).to eq(:expected)
        end
      end
    end

    describe "#signature" do
    end

    #TODO: Fix after helix_spec.yml
    let(:site_url) { "http://localhost:3000/0/1" }
    describe "#update" do
      let(:meth) { :update }
      subject { obj.method(meth) }
      its(:arity) { should eq(-1) }
      let(:params) { { signature: "2", nil => {} } }
      let(:site) { site_url + ".xml" }
      it "should call RestClient.put and return instance of klass" do
        set_stubs(obj)
        #TODO: Need to make an helix_spec.yml file
        RestClient.should_receive(:put).with(site, params)
        expect(obj.send(meth)).to be_an_instance_of(klass)
      end
    end

    describe "#load" do
      let(:meth) { :load }
      subject { obj.method(meth) }
      its(:arity) { should eq(-1) }
      let(:opts) { Hash.new }
      let(:url) { site_url + ".json" }
      it "should call .get_response and return instance of klass" do
        set_stubs(obj)
        klass.should_receive(:get_response).with(url, opts)
        expect(obj.send(meth)).to be_an_instance_of(klass)
      end
    end

  end

end
