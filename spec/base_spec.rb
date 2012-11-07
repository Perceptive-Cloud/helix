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

  describe "Constants" do
    describe "METHODS_DELEGATED_TO_CLASS" do
      subject { klass::METHODS_DELEGATED_TO_CLASS }
      it { should eq([:guid_name, :media_type_sym, :plural_media_type]) }
    end
  end

  ### CLASS METHODS

  describe ".create" do
    let(:meth)       { :create }
    subject          { klass.method(meth) }
    its(:arity)      { should eq(-1) }
    let(:resp_value) { { klass: { attribute: :value } } }
    let(:resp_json)  { "JSON" }
    let(:params)     { { signature: "some_sig" } }
    let(:expected)   { { attributes: { attribute: :value } } }
    before(:each) do
      klass.stub(:signature).with(:ingest) { "some_sig" }
      klass.stub(:plural_media_type) { :klasses }
      klass.stub(:media_type_sym)    { :klass }
    end
    it "should get an ingest signature" do
      url = klass.build_url(action:     :create_many,
                            media_type: :klasses)
      RestClient.stub(:post).with(url, params) { resp_json }
      JSON.stub(:parse).with(resp_json) { resp_value }
      klass.stub(:new).with(expected)
      klass.should_receive(:signature).with(:ingest) { "some_sig" }
      klass.send(meth)
    end
    it "should do an HTTP post call, parse response and call new" do
      url = klass.build_url(action:     :create_many,
                            media_type: :klasses)
      RestClient.should_receive(:post).with(url, params) { resp_json }
      JSON.should_receive(:parse).with(resp_json) { resp_value }
      klass.should_receive(:new).with(expected)
      klass.send(meth)
    end
  end

  describe "an instance" do
    let(:obj) { klass.new({}) }

    ### INSTANCE METHODS

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
                                    format:     :xml)
        RestClient.stub(:delete).with(url, params)
        mock_config.should_receive(:signature).with(:update) { :some_sig }
        obj.send(meth)
      end
      it "should call for an HTTP delete and return nil" do
        url = mock_config.build_url(media_type: :media_type,
                                    guid:       :some_guid,
                                    format:     :xml)
        RestClient.should_receive(:delete).with(url, params)
        expect(obj.send(meth)).to be_nil
      end
    end

    describe "#find" do
      let(:meth)  { :find }
      subject     { obj.method(meth) }
      its(:arity) { should eq(1) }
      context "when given a guid" do
        let(:guid) { :a_guid }
        let(:mock_attrs) { mock(Object, :[]= => :output_of_setting_val) }
        before(:each) do
          obj.stub(:attributes) { mock_attrs }
          obj.stub(:guid_name)  { :the_guid_name }
          obj.stub(:load)
        end
        it "should set attributes[guid_name] = the_guid" do
          obj.should_receive(:attributes).at_least(1).times { mock_attrs }
          mock_attrs.should_receive(:[]=).with(obj.guid_name, guid)
          obj.send(meth, guid)
        end
        it "should load" do
          obj.should_receive(:load)
          obj.send(meth, guid)
        end
      end
    end

    describe "#find_all" do
      let(:meth)  { :find_all }
      let(:mock_config) { mock(Helix::Config, build_url: :built_url, get_response: {}) }
      subject     { obj.method(meth) }
      its(:arity) { should eq(1) }
      context "when given an opts Hash" do
        let(:opts) { mock(Object, merge: :merged) }
        let(:plural_media_type) { :videos }
        before(:each) do
          obj.stub(:config) { mock_config }
          obj.stub(:plural_media_type) { plural_media_type }
        end
        it "should build a JSON URL -> the_url" do
          mock_config.should_receive(:build_url).with(format: :json)
          obj.send(meth, opts)
        end
        it "should get_response(the_url, opts.merge(sig_type: :view) -> raw_response" do
          opts.should_receive(:merge).with(sig_type: :view) { :opts_with_view_sig }
          mock_config.should_receive(:get_response).with(:built_url, :opts_with_view_sig)
          obj.send(meth, opts)
        end
        it "should read raw_response[plural_media_type] -> data_sets" do
          mock_raw_response = mock(Object)
          mock_config.stub(:get_response) { mock_raw_response }
          mock_raw_response.should_receive(:[]).with(plural_media_type)
          obj.send(meth, opts)
        end
        context "when data_sets is nil" do
          it "should return []" do expect(obj.send(meth, opts)).to eq([]) end
        end
        context "when data_sets is NOT nil" do
          let(:data_set) { (0..2).to_a }
          before(:each) do mock_config.stub(:get_response) { {plural_media_type => data_set } } end
          it "should map instantiation with attributes: each data set element" do
            klass.should_receive(:new).with(attributes: data_set[0]) { :a }
            klass.should_receive(:new).with(attributes: data_set[1]) { :b }
            klass.should_receive(:new).with(attributes: data_set[2]) { :c }
            expect(obj.send(meth, opts)).to eq([:a, :b, :c])
          end
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
        klass.stub(:media_type_sym)     { :video          }
      end
      shared_examples_for "builds URL for load" do
        it "should call #guid" do
          obj.should_receive(:guid) { 'some_guid' }
          obj.send(meth)
        end
        it "should build_url(format: :json, guid: the_guid, media_type: 'videos')" do
          mock_config.should_receive(:build_url).with(format: :json, guid: 'some_guid', media_type: 'videos')
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
            msg = "#{method_sym} is not recognized within #{klass}'s @attributes"
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
        it "should build_url(format: :xml, guid: guid, media_type: plural_media_type)" do
          mock_config.should_receive(:build_url).with(format: :xml, guid: :the_guid, media_type: :the_media_type)
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
