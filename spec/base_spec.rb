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
    let(:meth)                  { :create }
    subject                     { klass.method(meth) }
    its(:arity)                 { should eq(-1) }
    let(:resp_value)            { { klass: { attribute: :value } } }
    let(:resp_json)             { "JSON" }
    let(:params)                { { signature: "some_sig" } }
    before do 
      klass.stub(:signature)          { "some_sig" }
      klass.stub(:plural_media_type)  { :klasses }
      klass.stub(:media_type_sym)     { :klass }
    end
    it "should do an HTTP post call and parse response" do
      url = klass.build_url(action:     :create_many,
                            media_type: :klasses)
      RestClient.should_receive(:post).with(url, params) { resp_json }
      JSON.should_receive(:parse).with(resp_json) { resp_value }
      klass.send(meth)
    end
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
      context "and raw_response[plural_media_type] is nil" do
        before(:each) do klass.stub(:get_response) { {} } end
        subject { klass.send(meth, opts) }
        it { should eq([]) }
      end
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
    klass = Helix::Base
    shared_examples_for "reads scope from CREDENTIALS for build_url" do |media_type,format,more_opts|
      more_opts ||= {}
      guid   = more_opts[:guid]
      action = more_opts[:action]
      context "and CREDENTIALS has a key for 'reseller'" do
        before(:each) do klass::CREDENTIALS['reseller'] = 're_id' end
        context "and CREDENTIALS has a key for 'company'" do
          before(:each) do klass::CREDENTIALS['company'] = 'co_id' end
          context "and CREDENTIALS has a key for 'library'" do
            before(:each) do klass::CREDENTIALS['library'] = 'lib_id' end
            expected_url  = "#{klass::CREDENTIALS['site']}/resellers/re_id/companies/co_id/libraries/lib_id/#{media_type}"
            expected_url += "/the_guid"  if guid
            expected_url += "/#{action}" if action
            expected_url += ".#{format}"
            it { should eq(expected_url) }
          end
          context "and CREDENTIALS does NOT have a key for 'library'" do
            before(:each) do klass::CREDENTIALS.delete('library') end
            expected_url  = "#{klass::CREDENTIALS['site']}/resellers/re_id/companies/co_id/#{media_type}"
            expected_url += "/the_guid"  if guid
            expected_url += "/#{action}" if action
            expected_url += ".#{format}"
            it { should eq(expected_url) }
          end
        end
        context "and CREDENTIALS does NOT have a key for 'company'" do
          before(:each) do klass::CREDENTIALS.delete('company') end
          expected_url  = "#{klass::CREDENTIALS['site']}/resellers/re_id/#{media_type}"
          expected_url += "/the_guid"  if guid
          expected_url += "/#{action}" if action
          expected_url += ".#{format}"
          it { should eq(expected_url) }
        end
      end
      context "and CREDENTIALS does NOT have a key for 'reseller'" do
        before(:each) do klass::CREDENTIALS.delete('reseller') end
        context "and CREDENTIALS has a key for 'company'" do
          before(:each) do klass::CREDENTIALS['company'] = 'co_id' end
          context "and CREDENTIALS has a key for 'library'" do
            before(:each) do klass::CREDENTIALS['library'] = 'lib_id' end
            expected_url  = "#{klass::CREDENTIALS['site']}/companies/co_id/libraries/lib_id/#{media_type}"
            expected_url += "/the_guid"  if guid
            expected_url += "/#{action}" if action
            expected_url += ".#{format}"
            it { should eq(expected_url) }
          end
        end
      end
    end
    context "when given NO opts" do
      subject { klass.send(meth) }
      it_behaves_like "reads scope from CREDENTIALS for build_url", :videos, :json
    end
    context "when given opts of {}" do
      subject { klass.send(meth, {}) }
      it_behaves_like "reads scope from CREDENTIALS for build_url", :videos, :json
    end
    context "when given opts of {guid: :the_guid}" do
      subject { klass.send(meth, {guid: :the_guid}) }
      it_behaves_like "reads scope from CREDENTIALS for build_url", :videos, :json, {guid: :the_guid}
    end
    context "when given opts of {action: :the_action}" do
      subject { klass.send(meth, {action: :the_action}) }
      it_behaves_like "reads scope from CREDENTIALS for build_url", :videos, :json, {action: :the_action}
    end
    context "when given opts of {guid: :the_guid, action: :the_action}" do
      subject { klass.send(meth, {guid: :the_guid, action: :the_action}) }
      it_behaves_like "reads scope from CREDENTIALS for build_url", :videos, :json, {guid: :the_guid, action: :the_action}
    end
    [ :videos, :tracks ].each do |media_type|
      context "when given opts[:media_type] of :#{media_type}" do
        subject { klass.send(meth, media_type: media_type) }
        it_behaves_like "reads scope from CREDENTIALS for build_url", media_type, :json
      end
      context "when given opts[:media_type] of :#{media_type} and opts[:guid] of :the_guid" do
        subject { klass.send(meth, media_type: media_type, guid: :the_guid) }
        it_behaves_like "reads scope from CREDENTIALS for build_url", media_type, :json, {guid: :the_guid}
      end
      context "when given opts[:media_type] of :#{media_type} and opts[:action] of :the_action" do
        subject { klass.send(meth, media_type: media_type, action: :the_action) }
        it_behaves_like "reads scope from CREDENTIALS for build_url", media_type, :json, {action: :the_action}
      end
      context "when given opts[:media_type] of :#{media_type}, opts[:guid] of :the_guid, opts[:action] of :the_action" do
        subject { klass.send(meth, media_type: media_type, guid: :the_guid, action: :the_action) }
        it_behaves_like "reads scope from CREDENTIALS for build_url", media_type, :json, {guid: :the_guid, action: :the_action}
      end
    end
    [ :json, :xml ].each do |format|
      context "when given opts[:format] of :#{format}" do
        subject { klass.send(meth, format: format) }
        it_behaves_like "reads scope from CREDENTIALS for build_url", :videos, format
      end
      context "when given opts[:format] of :#{format} and opts[:guid] of :the_guid" do
        subject { klass.send(meth, format: format, guid: :the_guid) }
        it_behaves_like "reads scope from CREDENTIALS for build_url", :videos, format, {guid: :the_guid}
      end
      context "when given opts[:format] of :#{format} and opts[:action] of :the_action" do
        subject { klass.send(meth, format: format, action: :the_action) }
        it_behaves_like "reads scope from CREDENTIALS for build_url", :videos, format, {action: :the_action}
      end
      context "when given opts[:format] of :#{format}, opts[:guid] of :the_guid, and opts[:action] of :the_action" do
        subject { klass.send(meth, format: format, guid: :the_guid, action: :the_action) }
        it_behaves_like "reads scope from CREDENTIALS for build_url", :videos, format, {guid: :the_guid, action: :the_action}
      end
      [ :videos, :tracks ].each do |media_type|
        context "when given opts[:format] of :#{format} and opts[:media_type] of :#{media_type}" do
          subject { klass.send(meth, format: format, media_type: media_type) }
          it_behaves_like "reads scope from CREDENTIALS for build_url", media_type, format
        end
        context "when given opts[:format] of :#{format}, opts[:guid] of :the_guid, and opts[:media_type] of :#{media_type}" do
          subject { klass.send(meth, format: format, guid: :the_guid, media_type: media_type) }
          it_behaves_like "reads scope from CREDENTIALS for build_url", media_type, format, {guid: :the_guid}
        end
        context "when given opts[:format] of :#{format}, opts[:action] of :the_action, and opts[:media_type] of :#{media_type}" do
          subject { klass.send(meth, format: format, action: :the_action, media_type: media_type) }
          it_behaves_like "reads scope from CREDENTIALS for build_url", media_type, format, {action: :the_action}
        end
        context "when given opts[:format] of :#{format}, opts[:guid] of :the_guid, opts[:action] of :the_action, and opts[:media_type] of :#{media_type}" do
          subject { klass.send(meth, format: format, guid: :the_guid, action: :the_action, media_type: media_type) }
          it_behaves_like "reads scope from CREDENTIALS for build_url", media_type, format, {guid: :the_guid, action: :the_action}
        end
      end
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


  describe "an instance" do
    let(:obj) { klass.new({}) }

    describe "#destroy" do
      let(:meth)  { :destroy }
      subject     { obj.method(meth) }
      it "should call for an HTTP delete and return nil" do
        url = klass.build_url(media_type: :media_type)
        RestClient.should_receive(:delete).with(url)
        obj.stub(:plural_media_type) { :media_type }
        expect(obj.send(meth)).to be_nil
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
        it "should build_url(format: :json, guid: the_guid, media_type: 'videos')" do
          klass.should_receive(:build_url).with(format: :json, guid: 'some_guid', media_type: 'videos')
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
