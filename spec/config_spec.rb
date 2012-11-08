require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::Config do

  def set_stubs(obj, even_sig=false)
    obj.instance_variable_set(:@attributes, {})
    obj.stub(:media_type_sym)    { :video      }
    obj.stub(:plural_media_type) { 'videos'    }
    obj.stub(:guid)              { 'some_guid' }
    obj.stub(:signature)         { 'some_sig'  } if even_sig
  end

  let(:klass) { Helix::Config }
  let(:obj)   { klass.new }

  subject { klass }

  describe "Constants" do
    describe "DEFAULT_FILENAME" do
      subject { klass::DEFAULT_FILENAME }
      it { should eq('./helix.yml') }
    end
    describe "SCOPES" do
      subject { klass::SCOPES }
      it { should eq(%w(reseller company library)) }
    end
    describe "VALID_SIG_TYPES" do
      subject { klass::VALID_SIG_TYPES }
      it { should eq([:ingest, :update, :view]) }
    end
  end

  describe "#build_url" do
    site = 'http://example.com'
    let(:meth)  { :build_url }
    subject     { obj.method(meth) }
    its(:arity) { should be(-1) }
    before(:each) do
      obj.credentials = {'site' => site}
    end
    shared_examples_for "reads scope from credentials for build_url" do |media_type,format,more_opts|
      more_opts ||= {}
      guid   = more_opts[:guid]
      action = more_opts[:action]
      before(:each) do obj.credentials = {'site' => 'http://example.com'} end
      context "and credentials has a key for 'reseller'" do
        before(:each) do obj.credentials.merge!('reseller' => 're_id') end
        context "and credentials has a key for 'company'" do
          before(:each) do obj.credentials.merge!('company' => 'co_id') end
          context "and credentials has a key for 'library'" do
            before(:each) do obj.credentials.merge!('library' => 'lib_id') end
            expected_url  = "#{site}/resellers/re_id/companies/co_id/libraries/lib_id/#{media_type}"
            expected_url += "/the_guid"  if guid
            expected_url += "/#{action}" if action
            expected_url += ".#{format}"
            it { should eq(expected_url) }
          end
          context "and credentials does NOT have a key for 'library'" do
            before(:each) do obj.credentials.delete('library') end
            expected_url  = "#{site}/resellers/re_id/companies/co_id/#{media_type}"
            expected_url += "/the_guid"  if guid
            expected_url += "/#{action}" if action
            expected_url += ".#{format}"
            it { should eq(expected_url) }
          end
        end
        context "and credentials does NOT have a key for 'company'" do
          before(:each) do obj.credentials.delete('company') end
          expected_url  = "#{site}/resellers/re_id/#{media_type}"
          expected_url += "/the_guid"  if guid
          expected_url += "/#{action}" if action
          expected_url += ".#{format}"
          it { should eq(expected_url) }
        end
      end
      context "and credentials does NOT have a key for 'reseller'" do
        before(:each) do obj.credentials.delete('reseller') end
        context "and credentials has a key for 'company'" do
          before(:each) do obj.credentials['company'] = 'co_id' end
          context "and credentials has a key for 'library'" do
            before(:each) do obj.credentials['library'] = 'lib_id' end
            expected_url  = "#{site}/companies/co_id/libraries/lib_id/#{media_type}"
            expected_url += "/the_guid"  if guid
            expected_url += "/#{action}" if action
            expected_url += ".#{format}"
            it { should eq(expected_url) }
          end
        end
      end
    end
    context "when given NO opts" do
      subject { obj.send(meth) }
      it_behaves_like "reads scope from credentials for build_url", :videos, :json
    end
    context "when given opts of {}" do
      subject { obj.send(meth, {}) }
      it_behaves_like "reads scope from credentials for build_url", :videos, :json
    end
    context "when given opts of {guid: :the_guid}" do
      subject { obj.send(meth, {guid: :the_guid}) }
      it_behaves_like "reads scope from credentials for build_url", :videos, :json, {guid: :the_guid}
    end
    context "when given opts of {action: :the_action}" do
      subject { obj.send(meth, {action: :the_action}) }
      it_behaves_like "reads scope from credentials for build_url", :videos, :json, {action: :the_action}
    end
    context "when given opts of {guid: :the_guid, action: :the_action}" do
      subject { obj.send(meth, {guid: :the_guid, action: :the_action}) }
      it_behaves_like "reads scope from credentials for build_url", :videos, :json, {guid: :the_guid, action: :the_action}
    end
    [ :videos, :tracks ].each do |media_type|
      context "when given opts[:media_type] of :#{media_type}" do
        subject { obj.send(meth, media_type: media_type) }
        it_behaves_like "reads scope from credentials for build_url", media_type, :json
      end
      context "when given opts[:media_type] of :#{media_type} and opts[:guid] of :the_guid" do
        subject { obj.send(meth, media_type: media_type, guid: :the_guid) }
        it_behaves_like "reads scope from credentials for build_url", media_type, :json, {guid: :the_guid}
      end
      context "when given opts[:media_type] of :#{media_type} and opts[:action] of :the_action" do
        subject { obj.send(meth, media_type: media_type, action: :the_action) }
        it_behaves_like "reads scope from credentials for build_url", media_type, :json, {action: :the_action}
      end
      context "when given opts[:media_type] of :#{media_type}, opts[:guid] of :the_guid, opts[:action] of :the_action" do
        subject { obj.send(meth, media_type: media_type, guid: :the_guid, action: :the_action) }
        it_behaves_like "reads scope from credentials for build_url", media_type, :json, {guid: :the_guid, action: :the_action}
      end
    end
    [ :json, :xml ].each do |format|
      context "when given opts[:format] of :#{format}" do
        subject { obj.send(meth, format: format) }
        it_behaves_like "reads scope from credentials for build_url", :videos, format
      end
      context "when given opts[:format] of :#{format} and opts[:guid] of :the_guid" do
        subject { obj.send(meth, format: format, guid: :the_guid) }
        it_behaves_like "reads scope from credentials for build_url", :videos, format, {guid: :the_guid}
      end
      context "when given opts[:format] of :#{format} and opts[:action] of :the_action" do
        subject { obj.send(meth, format: format, action: :the_action) }
        it_behaves_like "reads scope from credentials for build_url", :videos, format, {action: :the_action}
      end
      context "when given opts[:format] of :#{format}, opts[:guid] of :the_guid, and opts[:action] of :the_action" do
        subject { obj.send(meth, format: format, guid: :the_guid, action: :the_action) }
        it_behaves_like "reads scope from credentials for build_url", :videos, format, {guid: :the_guid, action: :the_action}
      end
      [ :videos, :tracks ].each do |media_type|
        context "when given opts[:format] of :#{format} and opts[:media_type] of :#{media_type}" do
          subject { obj.send(meth, format: format, media_type: media_type) }
          it_behaves_like "reads scope from credentials for build_url", media_type, format
        end
        context "when given opts[:format] of :#{format}, opts[:guid] of :the_guid, and opts[:media_type] of :#{media_type}" do
          subject { obj.send(meth, format: format, guid: :the_guid, media_type: media_type) }
          it_behaves_like "reads scope from credentials for build_url", media_type, format, {guid: :the_guid}
        end
        context "when given opts[:format] of :#{format}, opts[:action] of :the_action, and opts[:media_type] of :#{media_type}" do
          subject { obj.send(meth, format: format, action: :the_action, media_type: media_type) }
          it_behaves_like "reads scope from credentials for build_url", media_type, format, {action: :the_action}
        end
        context "when given opts[:format] of :#{format}, opts[:guid] of :the_guid, opts[:action] of :the_action, and opts[:media_type] of :#{media_type}" do
          subject { obj.send(meth, format: format, guid: :the_guid, action: :the_action, media_type: media_type) }
          it_behaves_like "reads scope from credentials for build_url", media_type, format, {guid: :the_guid, action: :the_action}
        end
      end
    end
  end

  describe "#get_response" do
    let(:meth)  { :get_response }
    subject     { obj.method(meth) }
    its(:arity) { should eq(-2) }
    context "when given a url and options" do
      let(:string)        { String.new }
      let(:opts)          { {sig_type: :the_sig_type} }
      let(:params)        { { params: { signature: string } } }
      let(:returned_json) { '{"key": "val"}' }
      let(:json_parsed)   { { "key" => "val" } }
      it "should call RestClient.get and return a hash from parsed JSON" do
        obj.stub(:signature).with(:the_sig_type) { string }
        RestClient.should_receive(:get).with(string, params) { returned_json }
        expect(obj.send(meth, string, opts)).to eq(json_parsed)
      end
    end
  end

  describe "#signature" do
    let(:meth)  { :signature }
    subject     { obj.method(meth) }
    its(:arity) { should eq(1) }
    let(:mock_response) { mock(Object) }
    context "when given :some_invalid_sig_type" do
      let(:sig_type) { :some_invalid_sig_type }
      it "should raise an ArgumentError" do
        msg = "I don't understand 'some_invalid_sig_type'. Please give me one of :ingest, :update, or :view."
        expect(lambda { obj.send(meth, sig_type) }).to raise_error(ArgumentError, msg)
      end
    end
    context "when given :ingest" do
      let(:sig_type) { :ingest }
      url = %q[#{self.credentials['site']}/api/ingest_key?licenseKey=#{self.credentials['license_key']}&duration=1200]
      it "should call RestClient.get(#{url})" do
        set_stubs(obj)
        url = "#{obj.credentials['site']}/api/ingest_key?licenseKey=#{obj.credentials['license_key']}&duration=1200"
        RestClient.should_receive(:get).with(url) { :expected }
        expect(obj.send(meth, sig_type)).to be(:expected)
      end
    end
    context "when given :update" do
      let(:sig_type) { :update }
      url = %q[#{self.credentials['site']}/api/update_key?licenseKey=#{self.credentials['license_key']}&duration=1200]
      it "should call RestClient.get(#{url})" do
        set_stubs(obj)
        url = "#{obj.credentials['site']}/api/update_key?licenseKey=#{obj.credentials['license_key']}&duration=1200"
        RestClient.should_receive(:get).with(url) { :expected }
        expect(obj.send(meth, sig_type)).to be(:expected)
      end
    end
    context "when given :view" do
      let(:sig_type) { :view }
      url = %q[#{self.credentials['site']}/api/view_key?licenseKey=#{self.credentials['license_key']}&duration=1200]
      it "should call RestClient.get(#{url})" do
        set_stubs(obj)
        url = "#{obj.credentials['site']}/api/view_key?licenseKey=#{obj.credentials['license_key']}&duration=1200"
        RestClient.should_receive(:get).with(url) { :expected }
        expect(obj.send(meth, sig_type)).to be(:expected)
      end
    end
  end

end
