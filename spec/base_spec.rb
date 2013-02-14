require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::Base do

  def set_stubs(obj, even_sig=false)
    obj.instance_variable_set(:@attributes, {})
    obj.stub(:resource_label_sym)    { :video      }
    obj.stub(:plural_resource_label) { 'videos'    }
    obj.stub(:guid)                  { 'some_guid' }
    obj.stub(:signature)             { 'some_sig'  } if even_sig
  end

  let(:klass) { Helix::Base }

  subject { klass }

  describe "Constants" do
    describe "METHODS_DELEGATED_TO_CLASS" do
      subject { klass::METHODS_DELEGATED_TO_CLASS }
      it { should eq([:guid_name, :resource_label_sym, :plural_resource_label]) }
    end
  end

  ### CLASS METHODS

  describe ".config" do
    let(:meth)  { :config }
    subject     { klass.method(meth) }
    its(:arity) { should eq(0) }
    describe "when called" do
      subject     { klass.send(meth) }
      it { should eq(Helix::Config.instance) }
    end
  end

  shared_examples_for "a search all with opts" do
    let(:mock_config) { mock(Helix::Config, build_url: :built_url, get_response: {}) }
    subject           { klass.method(meth) }
    its(:arity)       { should eq(-1) }
    before(:each) do Helix::Config.stub(:instance) { mock_config } end
    context "when given a config instances and an opts Hash" do
      let(:opts) { {opts_key1: :opts_val1} }
      let(:plural_resource_label) { :videos }
      before(:each) do klass.stub(:plural_resource_label) { plural_resource_label } end
      it "should build a XML URL -> the_url" do
        mock_config.should_receive(:build_url).with(content_type:   :xml,
                                                    resource_label: plural_resource_label)
        klass.send(meth, opts)
      end
      it "should get_response(the_url, {sig_type: :view}.merge(opts) -> raw_response" do
        mock_config.should_receive(:get_response).with(:built_url, {sig_type: :view}.merge(opts))
        klass.send(meth, opts)
      end
      it "should read raw_response[plural_resource_label] -> data_sets" do
        mock_raw_response = mock(Object)
        mock_config.stub(:get_response) { mock_raw_response }
        mock_raw_response.should_receive(:[]).with(plural_resource_label)
        klass.send(meth, opts)
      end
      context "when data_sets is nil" do
        it "should return []" do expect(klass.send(meth, opts)).to eq([]) end
      end
      context "when data_sets is NOT nil" do
        let(:data_set) { (0..2).to_a }
        before(:each) do mock_config.stub(:get_response) { {plural_resource_label => data_set } } end
        it "should map instantiation with attributes: each data set element" do
          klass.should_receive(:new).with(attributes: data_set[0], config: mock_config) { :a }
          klass.should_receive(:new).with(attributes: data_set[1], config: mock_config) { :b }
          klass.should_receive(:new).with(attributes: data_set[2], config: mock_config) { :c }
          expect(klass.send(meth, opts)).to eq([:a, :b, :c])
        end
      end
    end
  end

  shared_examples_for "a search all without opts" do
    let(:mock_config) { mock(Helix::Config, build_url: :built_url, get_response: {}) }
    subject           { klass.method(meth) }
    before(:each) do Helix::Config.stub(:instance) { mock_config } end
    context "when given a config instances and NO opts Hash" do
      let(:plural_resource_label) { :videos }
      before(:each) do klass.stub(:plural_resource_label) { plural_resource_label } end
      it "should build a XML URL -> the_url" do
        mock_config.should_receive(:build_url).with(content_type:   :xml,
                                                    resource_label: plural_resource_label)
        klass.send(meth)
      end
      it "should get_response(the_url, {sig_type: :view} -> raw_response" do
        mock_config.should_receive(:get_response).with(:built_url, {sig_type: :view})
        klass.send(meth)
      end
      it "should read raw_response[plural_resource_label] -> data_sets" do
        mock_raw_response = mock(Object)
        mock_config.stub(:get_response) { mock_raw_response }
        mock_raw_response.should_receive(:[]).with(plural_resource_label)
        klass.send(meth)
      end
      context "when data_sets is nil" do
        it "should return []" do expect(klass.send(meth)).to eq([]) end
      end
      context "when data_sets is NOT nil" do
        let(:data_set) { (0..2).to_a }
        before(:each) do mock_config.stub(:get_response) { {plural_resource_label => data_set } } end
        it "should map instantiation with attributes: each data set element" do
          klass.should_receive(:new).with(attributes: data_set[0], config: mock_config) { :a }
          klass.should_receive(:new).with(attributes: data_set[1], config: mock_config) { :b }
          klass.should_receive(:new).with(attributes: data_set[2], config: mock_config) { :c }
          expect(klass.send(meth)).to eq([:a, :b, :c])
        end
      end
    end
  end

  describe ".find_all" do
    let(:meth) { :find_all }
    it_behaves_like "a search all with opts"
    it_behaves_like "a search all without opts"
  end

  describe ".all" do
    let(:meth)  { :all }
    subject     { klass.method(meth) }
    its(:arity) { should eq(0) }
    it_behaves_like "a search all without opts"
  end

  describe ".where" do
    let(:meth) { :where }
    it_behaves_like "a search all with opts"
    it_behaves_like "a search all without opts"
  end

  describe ".massage_attrs" do
    let(:meth)  { :massage_attrs }
    subject     { klass.method(meth) }
    its(:arity) { should eq(1) }
    let(:attrs) { Hash.new }
    it "should call massage_custom_field_attrs and massage_time_attrs" do
      klass.should_receive(:massage_time_attrs).and_return attrs
      klass.should_receive(:massage_custom_field_attrs).and_return attrs
      klass.send(meth, attrs)
    end
  end

  describe ".massage_time_attrs" do
    let(:meth)      { :massage_time_attrs }
    subject         { klass.method(meth) }
    its(:arity)     { should eq(1) }
    let(:time)      { Time.new(2013) }
    let(:attrs)     { { key_one: time.to_s, key_two: { key_three: time, key_four: { key_five: time.to_s } } } }
    let(:expected)  { { key_one: time, key_two: { key_three: time, key_four: { key_five: time } } } }
    it "should turn stringified time values into time objects" do
      expect(klass.send(meth, attrs)).to eq(expected)
    end
  end

  describe ".massage_custom_field_attrs" do
    let(:meth)        { :massage_custom_field_attrs }
    subject           { klass.method(meth) }
    its(:arity)       { should eq(1) }
    let(:custom_hash) { { "custom_fields" => {"boole"=>[nil, nil], "@type"=>"hash"} } }
    let(:expected)    { { "custom_fields" => [{"name"=>"boole", "value"=>""}, {"name"=>"boole", "value"=>""}] } }
    it "should turn custom_hash into expected" do
      expect(klass.send(meth, custom_hash)).to eq(expected)
    end
    it "should return the custom_hash in its form" do
      expect(klass.send(meth, expected)).to eq(expected)
    end
    let(:custom_hash_with_false)  { { "custom_fields" => {"boole"=>false, "@type"=>"hash"} } }
    let(:expected_with_false)     { { "custom_fields" => [{"name"=>"boole", "value"=>"false"}] } }
    it "should turn custom_hash into expected" do
      expect(klass.send(meth, custom_hash_with_false)).to eq(expected_with_false)
    end
  end

  describe "an instance" do
    let(:obj) { klass.new({}) }

    ### INSTANCE METHODS

    describe ".config" do
      let(:meth)  { :config }
      subject     { obj.method(meth) }
      its(:arity) { should eq(0) }
      describe "when called" do
        subject     { obj.send(meth) }
        context "and @config is already set" do
          before(:each) do obj.instance_variable_set(:@config, :cached_val) end
          it { should be(:cached_val) }
        end
        context "and @config is NOT already set" do
          before(:each) do obj.instance_variable_set(:@config, nil) end
          it { should eq(Helix::Config.instance) }
        end
      end
    end

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

    describe "#guid_name" do
      let(:meth) { :guid_name }
      it "should delegate to the class" do
        klass.should_receive(meth) { :expected }
        expect(obj.send(meth)).to be(:expected)
      end
    end

    describe "#load" do
      let(:meth)  { :load }
      let(:mock_config) { mock(Helix::Config) }
      subject     { obj.method(meth) }
      its(:arity) { should eq(-1) }
      before(:each) do
        obj.stub(:config)               { mock_config     }
        obj.stub(:guid)                 { 'some_guid'     }
        obj.stub(:signature)            { 'some_sig'      }
        obj.stub(:massage_raw_attrs)    { :massaged_attrs }
        mock_config.stub(:build_url)    { :expected_url   }
        mock_config.stub(:get_response) { :raw_attrs      }
        klass.stub(:resource_label_sym) { :video          }
      end
      shared_examples_for "builds URL for load" do
        it "should call #guid" do
          obj.should_receive(:guid) { 'some_guid' }
          obj.send(meth)
        end
        it "should build_url(content_type: :json, guid: the_guid, resource_label: 'videos')" do
          mock_config.should_receive(:build_url).with(content_type: :json, guid: 'some_guid', resource_label: 'videos')
          RestClient.stub(:put)
          obj.send(meth)
        end
      end
      context "when given no argument" do
        it_behaves_like "builds URL for load"
        it "should call klass.get_response(output_of_build_url, {sig_type: :view}) and return instance of klass" do
          mock_config.should_receive(:get_response).with(:expected_url, {sig_type: :view})
          expect(obj.send(meth)).to be_an_instance_of(klass)
        end
        it "should massage the raw_attrs" do
          obj.should_receive(:massage_raw_attrs).with(:raw_attrs)
          obj.send(meth)
        end
      end
      context "when given an opts argument of {key1: :value1}" do
        let(:opts)  { {key1: :value1} }
        it_behaves_like "builds URL for load"
        it "should call klass.get_response(output_of_build_url, opts.merge(sig_type: :view)) and return instance of klass" do
          mock_config.should_receive(:get_response).with(:expected_url, opts.merge(sig_type: :view))
          expect(obj.send(meth, opts)).to be_an_instance_of(klass)
        end
        it "should massage the raw_attrs" do
          obj.should_receive(:massage_raw_attrs).with(:raw_attrs)
          obj.send(meth, opts)
        end
      end
    end

    describe "#massage_raw_attrs" do
      let(:meth)      { :massage_raw_attrs }
      let(:guid_name) { :the_guid_name }

      subject     { obj.method(meth) }
      its(:arity) { should eq(1) }

      before(:each) { obj.stub(:guid_name) { guid_name } }
      context "when given {}" do
        let(:raw_attrs) { {} }
        subject { obj.send(meth, raw_attrs) }
        it { should eq(nil) }
      end
      context "when given { guid_name => :the_val }" do
        let(:raw_attrs) { { guid_name => :the_val } }
        subject { obj.send(meth, raw_attrs) }
        it { should eq(raw_attrs) }
      end
      context "when given [{ guid_name => :the_val }]" do
        let(:raw_attrs) { [{ guid_name => :the_val }] }
        subject { obj.send(meth, raw_attrs) }
        it { should eq(raw_attrs.first) }
      end
    end

    describe "#method_missing" do
      let(:meth)  { :method_missing }
      subject     { obj.method(meth) }
      its(:arity) { should eq(1) }
      context "when given method_sym" do
        let(:method_sym) { :method_sym }
        let(:mock_attributes) { mock(Object) }
        before(:each) do obj.instance_variable_set(:@attributes, mock_attributes) end
        context "and @attributes[method_sym.to_s] raises an exception" do
          before(:each) do mock_attributes.should_receive(:[]).with(method_sym.to_s).and_raise("some exception") end
          it "should raise a NoMethodError" do
            msg = "#{method_sym} is not recognized within #{klass}'s methods or @attributes"
            expect(lambda { obj.send(meth, method_sym) }).to raise_error(msg)
          end
        end
        context "and @attributes[method_sym.to_s] does NOT raise an exception" do
          before(:each) do mock_attributes.should_receive(:[]).with(method_sym.to_s) { :expected } end
          it "should return @attributes[method_sym.to_s]" do
            expect(obj.send(meth, method_sym)).to eq(:expected)
          end
        end
      end
    end

  end

end
