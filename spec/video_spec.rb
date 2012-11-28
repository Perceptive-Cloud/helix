require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::Video do

  def import_xml(values={})
    { list: { entry: values } }.to_xml(root: :add)
  end

  let(:klass) { Helix::Video }

  subject                 { klass }
  its(:ancestors)         { should include(Helix::Base) }
  its(:guid_name)         { should eq('video_id') }
  its(:media_type_sym)    { should be(:video)   }
  its(:plural_media_type) { should eq('videos') }

  describe "Constants"

  let(:sig_opts)  { { contributor:  :helix, 
                      library_id:   :development } }
  let(:url_opts)  { { action:       :create_many, 
                      media_type:   "videos", 
                      format:       :xml } }

  describe "an instance" do
    let(:obj)             { klass.new({'video_id' => 'some_video_guid'}) }
    subject               { obj }
    its(:media_type_sym)  { should be(:video) }
  end

  describe ".import" do
    let(:meth)        { :import }
    let(:mock_config) { mock(Helix::Config) }
    subject           { klass.method(meth) }
    its(:arity)       { should eq(-1) }
    let(:params)      { { params: { signature: :some_sig } } }  
    before            { Helix::Config.stub(:instance) { mock_config } } 

    it "should get an ingest signature" do
      mock_config.should_receive(:build_url).with(url_opts)
      mock_config.should_receive(:signature).with(:ingest, sig_opts) { :some_sig }
      RestClient.should_receive(:post).with(nil, import_xml, params)
      klass.send(meth)
    end
  end

  describe ".get_xml" do 
    let(:meth)  { :get_xml }
    subject     { klass.method(meth) }
    its(:arity) { should eq(-1) }
    context "when :use_raw_xml is present in attrs" do
      let(:use_raw_xml) { { use_raw_xml: :xml } }
      it "should return the value of attrs[:use_raw_xml]" do
        expect(klass.send(meth, use_raw_xml)).to eq(:xml)
      end
    end
    context "when hash is passed without :use_raw_xml" do
      let(:attrs) { { attribute: :value } }
      it "should convert attrs into xml" do
        expect(klass.send(meth, attrs)).to eq(import_xml(attrs))
      end
    end
    context "when nothing in passed in" do
      it "should return valid xml" do
        expect(klass.send(meth)).to eq(import_xml)
      end
    end
  end

  describe ".get_url_opts" do
    let(:meth)  { :get_url_opts }
    subject     { klass.method(meth) }
    its(:arity) { should eq(0) }
    it "should return a valid hash url options for Helix::Config#build_url" do
       expect(klass.send(meth)).to eq(url_opts)
    end
  end

  describe ".get_url" do
    let(:meth)  { :get_url }
    subject     { klass.method(meth) }
    its(:arity) { should eq(0) }
    it "should call Helix::Config#build_url with url opts" do
      Helix::Config.instance.should_receive(:build_url).with(klass.send(:get_url_opts))
      klass.send(meth)
    end
  end

  describe ".get_params" do
    let(:meth)  { :get_params }
    subject     { klass.method(meth) }
    its(:arity) { should eq(-1) }
    it "should call Helix::Config#signature and return a hash of params" do
      Helix::Config.instance.should_receive(:signature).with(:ingest, sig_opts) { :sig }
      expect(klass.send(meth)).to eq({ params: { signature: :sig } })
    end
  end

  describe ".extract_params" do
    let(:meth)          { :extract_params }
    subject             { klass.method(meth) }
    its(:arity)         { should eq(1) }
    let(:expected_hash) { { contributor: :con, library_id: :id } }
    let(:attrs)         { { extra_key_one: :one, 
                            extra_key_two: :two }.merge(expected_hash) }
    it "should return the correct key values from attributes" do
      expect(klass.send(meth, attrs)).to eq(expected_hash)
    end
  end


end
