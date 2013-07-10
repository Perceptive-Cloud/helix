require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::Track do

  let(:klass) { Helix::Track }
  subject     { klass }
  mods = [ Helix::Base, Helix::Durationed, Helix::Media ]
  mods.each { |mod| its(:ancestors) { should include(mod) } }
  its(:guid_name)             { should eq('track_id') }
  its(:resource_label_sym)    { should be(:track)     }
  its(:plural_resource_label) { should eq('tracks')   }
  [:find, :create, :all, :find_all, :where].each do |crud_call|
    it { should respond_to(crud_call) }
  end

  describe "Constants"

  ### INSTANCE METHODS

  describe "an instance" do
    let(:obj)            { klass.new({'track_id' => 'some_track_guid'}) }
    subject              { obj }
    its(:resource_label_sym) { should be(:track) }
    [:destroy, :update].each do |crud_call|
      it { should respond_to(crud_call) }
    end
  end

  ### CLASS METHODS

  describe ".upload" do
    let(:meth)            { :upload }
    let(:mock_config)     { double(Helix::Config) }
    subject               { klass.method(meth) }
    its(:arity)           { should eq(1) }
    let(:file_hash)       { { file: :some_file  } }
    let(:multipart_hash)  { { multipart: true } }
    it "should call upload_server_name and RestClient.post with params" do
      klass.should_receive(:upload_server_name) { :some_server_url }
      File.should_receive(:new).with(:some_file.to_s, "rb") { :some_file }
      RestClient.should_receive(:post).with(:some_server_url,
                                            file_hash,
                                            multipart_hash)
      klass.should_receive(:http_close)
      klass.send(meth, :some_file)
    end
  end

  describe ".upload_server_name" do
    let(:meth)        { :upload_server_name }
    let(:mock_config) { double(Helix::Config) }
    subject           { klass.method(meth) }
    its(:arity)       { should eq(0) }
    let(:url_opts)    { { resource_label: "upload_sessions",
                          guid:           :some_sig,
                          action:         :http_open,
                          content_type:   ""  } }
    before            { Helix::Config.stub(:instance) { mock_config } }
    it "should call RestClient.get with correct url building" do
      mock_config.should_receive(:build_url).with(url_opts) { :url }
      mock_config.should_receive(:signature).with(:ingest) { :some_sig }
      RestClient.should_receive(:get).with(:url)
      klass.send(meth)
    end
  end

  describe ".http_close" do
    let(:meth)        { :http_close }
    let(:mock_config) { double(Helix::Config) }
    subject           { klass.method(meth) }
    its(:arity)       { should eq(0) }
    let(:url_opts)    { { resource_label: "upload_sessions",
                          guid:           :some_sig,
                          action:         :http_close,
                          content_type:   ""  } }
    before            { Helix::Config.stub(:instance) { mock_config } }
    it "should call RestClient.get with correct url building" do
      mock_config.should_receive(:build_url).with(url_opts) { :url }
      mock_config.should_receive(:signature).with(:ingest) { :some_sig }
      RestClient.should_receive(:get).with(:url)
      klass.send(meth)
    end
  end

  describe ".upload_get" do
    let(:meth)        { :upload_get }
    let(:mock_config) { double(Helix::Config) }
    subject           { klass.method(meth) }
    its(:arity)       { should eq(1) }
    let(:url_opts)    { { resource_label: "upload_sessions",
                          guid:           :some_sig,
                          action:         :upload_get,
                          content_type:   ""  } }
    before            { Helix::Config.stub(:instance) { mock_config } }
    it "should call RestClient.get with correct url building" do
      mock_config.should_receive(:build_url).with(url_opts) { :url }
      mock_config.should_receive(:signature).with(:ingest) { :some_sig }
      RestClient.should_receive(:get).with(:url)
      klass.send(meth, :upload_get)
    end
  end

  describe ".http_open" do
    let(:meth)        { :http_open }
    let(:mock_config) { double(Helix::Config) }
    subject           { klass.method(meth) }
    its(:arity)       { should eq(0) }
    it "should call upload_server_name" do
      klass.should_receive(:upload_server_name)
      klass.send(meth)
    end
  end

  describe ".upload_open" do
    let(:meth)        { :upload_open }
    let(:mock_config) { double(Helix::Config) }
    subject           { klass.method(meth) }
    its(:arity)       { should eq(0) }
    it "should call upload_server_name" do
      klass.should_receive(:upload_server_name)
      klass.send(meth)
    end
  end

  describe ".upload_close" do
    let(:meth)        { :upload_close }
    let(:mock_config) { double(Helix::Config) }
    subject           { klass.method(meth) }
    its(:arity)       { should eq(0) }
    it "should call upload_server_name" do
      klass.should_receive(:http_close)
      klass.send(meth)
    end
  end

end
