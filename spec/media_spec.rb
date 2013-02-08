require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::Media do

  let(:klass) { Helix::Media }

  subject { klass }

  describe ".create" do
    let(:meth)        { :create }
    let(:mock_config) { mock(Helix::Config) }
    subject           { klass.method(meth) }
    its(:arity)       { should eq(-1) }
    let(:klass_sym)   { :klass }
    let(:resp_value)  { { klass_sym.to_s => { attribute: :value } } }
    let(:resp_json)   { "JSON" }
    let(:params)      { { signature: "some_sig" } }
    let(:expected)    { { attributes: { attribute: :value }, config: mock_config } }
    before(:each) do
      klass.stub(:plural_media_type) { :klasses }
      klass.stub(:media_type_sym)    { klass_sym }
      mock_config.stub(:build_url).with(action: :create_many, media_type: :klasses) { :url }
      mock_config.stub(:signature).with(:update) { "some_sig" }
      Helix::Config.stub(:instance) { mock_config }
    end
    it "should get an ingest signature" do
      mock_config.should_receive(:build_url).with(media_type:   :klasses,
                                                  content_type: :xml)
      RestClient.stub(:post).with(:url, params) { resp_json }
      Hash.should_receive(:from_xml).with(resp_json) { resp_value }
      klass.stub(:new).with(expected)
      mock_config.should_receive(:signature).with(:update) { "some_sig" }
      klass.send(meth)
    end
    it "should do an HTTP post call, parse response and call new" do
      mock_config.should_receive(:build_url).with(media_type:   :klasses,
                                                  content_type: :xml)
      RestClient.should_receive(:post).with(:url, params) { resp_json }
      Hash.should_receive(:from_xml).with(resp_json)      { resp_value }
      klass.should_receive(:new).with(expected)
      klass.send(meth)
    end
  end

  describe ".find" do
    let(:meth)        { :find }
    let(:mock_config) { mock(Helix::Config) }
    let(:mock_obj)    { mock(klass, :load => :output_of_load) }
    subject     { klass.method(meth) }
    its(:arity) { should eq(1) }
    before(:each) do Helix::Config.stub(:instance) { mock_config } end
    context "when given a Helix::Config instance and a guid" do
      let(:guid)       { :a_guid }
      let(:guid_name)  { :the_guid_name }
      let(:mock_attrs) { mock(Object, :[]= => :output_of_setting_val) }
      before(:each) do
        klass.stub(:attributes) { mock_attrs }
        klass.stub(:guid_name)  { guid_name  }
        klass.stub(:new)        { mock_obj }
      end
      it "should instantiate with {attributes: guid_name => the_guid, config: config}" do
        klass.should_receive(:new).with({attributes: {guid_name => guid}, config: mock_config})
        klass.send(meth, guid)
      end
      it "should load" do
        mock_obj.should_receive(:load)
        klass.send(meth, guid)
      end
    end
  end

  describe "an instance" do
    let(:obj) { klass.new({}) }

    describe "#destroy" do
      let(:meth)   { :destroy }
      let(:mock_config) { mock(Helix::Config, build_url: :the_built_url, signature: :some_sig) }
      subject      { obj.method(meth) }
      let(:params) { { params: {signature: :some_sig } } }
      before do
        obj.stub(:config)            { mock_config }
        obj.stub(:guid)              { :some_guid  }
        obj.stub(:plural_media_type) { :media_type }
      end
      it "should get an update signature" do
        url = mock_config.build_url(media_type: :media_type,
                                    guid:       :some_guid,
                                    content_type:     :xml)
        RestClient.stub(:delete).with(url, params)
        mock_config.should_receive(:signature).with(:update) { :some_sig }
        obj.send(meth)
      end
      it "should call for an HTTP delete and return nil" do
        url = mock_config.build_url(media_type: :media_type,
                                    guid:       :some_guid,
                                    content_type:     :xml)
        RestClient.should_receive(:delete).with(url, params)
        expect(obj.send(meth)).to be_nil
      end
    end
    describe "#update" do
      let(:meth)  { :update }
      let(:mock_config) { mock(Helix::Config) }
      subject     { obj.method(meth) }
      its(:arity) { should eq(-1) }
      before(:each) do
        obj.stub(:config) { mock_config }
        obj.stub(:guid)   { :the_guid }
        obj.stub(:media_type_sym) { :video }
        obj.stub(:plural_media_type) { :the_media_type }
        mock_config.stub(:signature).with(:update) { 'some_sig' }
        mock_config.stub(:build_url) { :expected_url }
      end
      shared_examples_for "builds URL for update" do
        it "should build_url(content_type: :xml, guid: guid, media_type: plural_media_type)" do
          mock_config.should_receive(:build_url).with(content_type: :xml, guid: :the_guid, media_type: :the_media_type)
          RestClient.stub(:put)
          obj.send(meth)
        end
        it "should get an update signature" do
          mock_config.stub(:build_url)
          RestClient.stub(:put)
          mock_config.should_receive(:signature).with(:update) { 'some_sig' }
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