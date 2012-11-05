require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::Base do

  def set_stubs(obj, even_sig=false)
    obj.instance_variable_set(:@attributes, {})
    obj.stub(:media_type_sym)    { :video      }
    obj.stub(:plural_media_type) { 'videos'    }
    obj.stub(:guid)              { 'some_guid' }
    obj.stub(:signature)         { 'some_sig'  } if even_sig
  end

  let(:klass) { Helix::Base }

  subject { klass }

  describe ".create" do
    let(:meth) { :create }
    subject { klass.method(meth) }
    its(:arity) { should eq(-1) }
    #it "should make an api call get the instance data" do
    #  params  = Hash.new
    #  url     = "#{klass::CREDENTIALS['site']}/#{obj.send(:plural_media_type)}/"
    #  RestClient.should_receive(:post).with(urm, params)
    #end
    #it "should create an klass instance and save it" do
    #  obj = klass.send(meth)
    #  expect(obj).to be_an_instance_of(klass)
    #  expect(klass.find(obj.id)).to be_an_instance_of(klass)
    #end
  end

  describe ".find" do
    let(:meth)  { :find }
    subject     { klass.method(meth) }
    its(:arity) { should eq(1) }
    context "when given a guid" do
      subject             { klass }
      let(:guid)          { :a_guid }
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

  describe ".find_all" do
    let(:meth)  { :find_all }
    subject     { klass.method(meth) }
    its(:arity) { should eq(1) }
    context "when called with multiple { attribute: :value }" do
      let(:opts)        { Hash.new }
      let(:attr_value)  { { attribute: :value } }
      let(:attrs_hash)  { { attributes: attr_value } }
      let(:obj_count)   { 2 }
      before(:each) do
        klass.stub(:get_response) do
          { klasses: (1..obj_count).map { attr_value } }
        end
        klass.stub(:plural_media_type) { :klasses }
      end
      it "should call new for each object with attribute hashes" do
        klass.should_receive(:new).exactly(obj_count).times
        klass.send(meth, opts)
      end
      subject { klass.send(meth, opts).first }
      it { should be_an_instance_of(klass) }
      it "should have equal attributes for those passed in" do
        attrs = klass.send(meth, opts).map {|k| { attributes: k.attributes }}
        expect(attrs).to eq((1..obj_count).map { attrs_hash })
      end
      subject { klass.send(meth, opts).first }
      it { should be_an_instance_of(klass) }
    end
  end

#TODO: Possible cleanup.
  describe ".get_response" do
    let(:meth)  { :get_response }
    subject     { klass.method(meth) }
    its(:arity) { should eq(-2) }
    context "when given a url and options" do
      subject             { klass }
      let(:string)        { String.new }
      let(:opts)          { Hash.new }
      let(:params)        { { params: { signature: string } } }
      let(:returned_json) { '{"key": "val"}' }
      let(:json_parsed)   { { "key" => "val" } }
      it "should call RestClient.get and return a hash from parsed JSON" do
        klass.stub(:signature) { string }
        RestClient.should_receive(:get).with(string, params) { returned_json }
        expect(klass.send(meth, string, opts)).to eq(json_parsed)
      end
    end
  end

  describe ".build_url" do
    let(:meth)  { :build_url }
    subject     { klass.method(meth) }
    its(:arity) { should be(-1) }
    before      { klass.stub(:plural_media_type) { "klasses" } }
    context "when given NO opts" do
      subject { klass.send(meth) }
      it      { should eq("#{klass::CREDENTIALS['site']}/klasses.json") }
    end
    context "when given opts of {}" do
      subject { klass.send(meth, {}) }
      it      { should eq("#{klass::CREDENTIALS['site']}/klasses.json") }
    end
    context "when given opts[:format] of :json" do
      subject { klass.send(meth, format: :json) }
      it      { should eq("#{klass::CREDENTIALS['site']}/klasses.json") }
    end
    context "when given opts[:format] of :xml" do
      subject { klass.send(meth, format: :xml) }
      it      { should eq("#{klass::CREDENTIALS['site']}/klasses.xml") }
    end
  end

  describe ".signature" do
    let(:meth) { :signature }
    let(:obj)  { mock(Object) }
    it "should delegate to an instance" do
      klass.should_receive(:new).with({}) { obj }
      obj.should_receive(meth) { :expected }
      expect(klass.send(meth)).to be(:expected)
    end
  end

  describe "Constants"

  # attr_accessor attributes

  describe "#destroy" do
    let(:meth)  { :destroy }
    #it "should delete the record" do
    #  obj = klass.create
    #  expect(klass.find(obj.id)).to be_an_instance_of(klass)
    #  obj.method(meth)
    #  expect(obj = klass.find(obj.id)).to be_nil
    #end
  end

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

    describe "#load" do
      let(:meth)  { :load }
      subject     { obj.method(meth) }
      its(:arity) { should eq(-1) }
      before(:each) do
        obj.stub(:guid)           { 'some_guid'   }
        obj.stub(:signature)      { 'some_sig'    }
        obj.stub(:media_type_sym) { :video        }
        klass.stub(:build_url)    { :expected_url }
        klass.stub(:get_response) { :expected_url }
      end
      shared_examples_for "builds URL for load" do
        it "should call #guid" do
          obj.should_receive(:guid) { 'some_guid' }
          obj.send(meth)
        end
        it "should build_url(format: :json, guid: the_guid)" do
          klass.should_receive(:build_url).with(format: :json, guid: 'some_guid')
          RestClient.stub(:put)
          obj.send(meth)
        end
      end
      context "when given no argument" do
        it_behaves_like "builds URL for load"
        it "should call klass.get_response(output_of_build_url, {}) and return instance of klass" do
          klass.should_receive(:get_response).with(:expected_url, {})
          expect(obj.send(meth)).to be_an_instance_of(klass)
        end
      end
      context "when given an opts argument of {key1: :value1}" do
        let(:opts)  { {key1: :value1} }
        it_behaves_like "builds URL for load"
        it "should call klass.get_response(output_of_build_url, opts) and return instance of klass" do
          klass.should_receive(:get_response).with(:expected_url, opts)
          expect(obj.send(meth, opts)).to be_an_instance_of(klass)
        end
      end
    end

    describe "#method_missing" do
      let(:meth)  { :method_missing }
      subject     { obj.method(meth) }
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
      let(:meth)  { :signature }
      subject     { obj.method(meth) }
      its(:arity) { should eq(0) }
      let(:mock_response) { mock(Object) }
      url = %q[#{CREDENTIALS['site']}/api/update_key?licenseKey=#{CREDENTIALS['license_key']}&duration=1200]
      it "should call Net::HTTP.get_response(URI.parse(#{url})).body" do
        set_stubs(obj)
        url = "#{klass::CREDENTIALS['site']}/api/update_key?licenseKey=#{klass::CREDENTIALS['license_key']}&duration=1200"
        URI.should_receive(:parse).with(url) { :parsed_url }
        Net::HTTP.should_receive(:get_response).with(:parsed_url) { mock_response }
        mock_response.should_receive(:body) { :expected }
        expect(obj.send(meth)).to be(:expected)
      end
    end

    describe "#update" do
      let(:meth)  { :update }
      subject     { obj.method(meth) }
      its(:arity) { should eq(-1) }
      before(:each) do
        obj.stub(:signature) { 'some_sig' }
        obj.stub(:media_type_sym) { :video }
        klass.stub(:build_url) { :expected_url }
      end
      shared_examples_for "builds URL for update" do
        it "should build_url(format: :xml)" do
          klass.should_receive(:build_url).with(format: :xml)
          RestClient.stub(:put)
          obj.send(meth)
        end
      end
      context "when given no argument" do
        it_behaves_like "builds URL for update"
        it "should call RestClient.put(output_of_build_url, {signature: the_sig, video: {}}) and return instance of klass" do
          RestClient.should_receive(:put).with(:expected_url, {signature: 'some_sig', video: {}})
          expect(obj.send(meth)).to be_an_instance_of(klass)
        end
      end
      context "when given an opts argument of {key1: :value1}" do
        let(:opts)  { {key1: :value1} }
        it_behaves_like "builds URL for update"
        it "should call RestClient.put(output_of_build_url, {signature: the_sig, video: opts}) and return instance of klass" do
          RestClient.should_receive(:put).with(:expected_url, {signature: 'some_sig', video: opts})
          expect(obj.send(meth, opts)).to be_an_instance_of(klass)
        end
      end
    end

  end

end
