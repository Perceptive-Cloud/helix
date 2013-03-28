require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::Media do

  let(:klass) { Helix::Media }

  subject { klass }

  mods = [ Helix::RESTful ]
  mods.each { |mod| its(:ancestors) { should include(mod) } }

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
    context "when a Helix:Config instance is absent" do
      before(:each) do Helix::Config.stub(:instance) { nil } end
      it "should raise a NoConfigurationLoaded exception" do
        lambda { klass.send(meth) }.should raise_error(Helix::NoConfigurationLoaded)
      end
    end
    context "when a Helix:Config instance is present" do
      before(:each) do
        klass.stub(:plural_resource_label) { :klasses }
        klass.stub(:resource_label_sym)    { klass_sym }
        mock_config.stub(:build_url).with(action: :create_many, resource_label: :klasses) { :url }
        mock_config.stub(:signature).with(:update) { "some_sig" }
        Helix::Config.stub(:instance) { mock_config }
      end
      it "should get an ingest signature" do
        mock_config.should_receive(:build_url).with(resource_label: :klasses,
                                                    content_type:   :xml)
        RestClient.stub(:post).with(:url, params) { resp_json }
        Hash.should_receive(:from_xml).with(resp_json) { resp_value }
        klass.stub(:new).with(expected)
        mock_config.should_receive(:signature).with(:update) { "some_sig" }
        klass.send(meth)
      end
      it "should do an HTTP post call, parse response and call new" do
        mock_config.should_receive(:build_url).with(resource_label: :klasses,
                                                    content_type:   :xml)
        RestClient.should_receive(:post).with(:url, params) { resp_json }
        Hash.should_receive(:from_xml).with(resp_json)      { resp_value }
        klass.should_receive(:new).with(expected)
        klass.send(meth)
      end
    end
  end

  describe ".find" do
    let(:meth)        { :find }
    let(:mock_config) { mock(Helix::Config) }
    let(:mock_obj)    { mock(klass, :load => :output_of_load) }
    subject     { klass.method(meth) }
    its(:arity) { should eq(1) }
    context "when a Helix:Config instance is absent" do
      before(:each) do Helix::Config.stub(:instance) { nil } end
      context "and given a guid" do
        let(:guid_name)  { :the_guid_name }
        let(:mock_attrs) { mock(Object, :[]= => :output_of_setting_val) }
        before(:each) do
          klass.stub(:attributes) { mock_attrs }
          klass.stub(:guid_name)  { guid_name  }
          klass.stub(:new)        { mock_obj }
        end
        context "and the guid is nil" do
          it "should raise an ArgumentError complaining about a nil guid" do
            msg = 'find requires a non-nil guid argument - received a nil argument.'
            lambda { klass.send(meth, nil) }.should raise_error(ArgumentError, msg)
          end
        end
        context "and the guid is non-nil" do
          let(:guid) { :a_guid }
          it "should raise a NoConfigurationLoaded exception" do
            lambda { klass.send(meth, guid) }.should raise_error(Helix::NoConfigurationLoaded)
          end
        end
      end
    end
    context "when a Helix::Config instance is present" do
      before(:each) do Helix::Config.stub(:instance) { mock_config } end
      context "and given a guid" do
        let(:guid_name)  { :the_guid_name }
        let(:mock_attrs) { mock(Object, :[]= => :output_of_setting_val) }
        before(:each) do
          klass.stub(:attributes) { mock_attrs }
          klass.stub(:guid_name)  { guid_name  }
          klass.stub(:new)        { mock_obj }
        end
        context "and the guid is nil" do
          it "should raise an ArgumentError complaining about a nil guid" do
            msg = 'find requires a non-nil guid argument - received a nil argument.'
            lambda { klass.send(meth, nil) }.should raise_error(ArgumentError, msg)
          end
        end
        context "and the guid is non-nil" do
          let(:guid) { :a_guid }
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
        obj.stub(:plural_resource_label) { :resource_label }
      end
      it "should get an update signature" do
        url = mock_config.build_url(resource_label: :resource_label,
                                    guid:           :some_guid,
                                    content_type:   :xml)
        RestClient.stub(:delete).with(url, params)
        mock_config.should_receive(:signature).with(:update) { :some_sig }
        obj.send(meth)
      end
      it "should call for an HTTP delete and return nil" do
        url = mock_config.build_url(resource_label: :resource_label,
                                    guid:           :some_guid,
                                    content_type:   :xml)
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
        obj.stub(:resource_label_sym) { :video }
        obj.stub(:plural_resource_label) { :the_resource_label }
        mock_config.stub(:signature).with(:update) { 'some_sig' }
        mock_config.stub(:build_url) { :expected_url }
      end
      shared_examples_for "builds URL for update" do
        it "should build_url(content_type: :xml, guid: guid, resource_label: plural_resource_label)" do
          mock_config.should_receive(:build_url).with(content_type: :xml, guid: :the_guid, resource_label: :the_resource_label)
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
        it "clones the opts arg" do
          RestClient.stub(:put).with(:expected_url, {signature: 'some_sig', video: opts})
          opts.should_receive(:clone) { opts }
          obj.send(meth, opts)
        end
        it "should call RestClient.put(output_of_build_url, {signature: the_sig, video: opts}) and return instance of klass" do
          RestClient.should_receive(:put).with(:expected_url, {signature: 'some_sig', video: opts})
          expect(obj.send(meth, opts)).to be_an_instance_of(klass)
        end
      end
    end
  end
end
