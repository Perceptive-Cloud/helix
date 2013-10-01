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

    describe "#download" do
      let(:meth)        { :download }
      let(:mock_config) { double(Helix::Config, build_url: :the_built_url, signature: :some_sig) }
      subject      { obj.method(meth) }
      let(:params) { { params: {signature: :some_sig } } }
      before do
        obj.stub(:config)            { mock_config }
        obj.stub(:guid)              { :some_guid  }
        obj.stub(:plural_resource_label) { :resource_label }
        RestClient.stub(:get) { '' }
      end
      { '' => '', mp3: :mp3, nil => '' }.each do |arg,actual|
        build_url_h = {action: :file, content_type: actual, guid: :some_guid, resource_label: :resource_label}
        context "when given {content_type: #{arg}" do
          it "should build_url(#{build_url_h})" do
            mock_config.should_receive(:build_url).with(build_url_h)
            obj.send(meth, content_type: arg)
          end
          it "should get a view signature" do
            mock_config.should_receive(:signature).with(:view) { :some_sig }
            obj.send(meth, content_type: arg)
          end
          it "should return an HTTP get to the built URL with the view sig" do
            mock_config.stub(:build_url).with(build_url_h) { :the_url }
            RestClient.should_receive(:get).with(:the_url, params) { :expected }
            expect(obj.send(meth, content_type: arg)).to be(:expected)
          end
        end
      end
    end

    describe "#play" do
      let(:meth)        { :play }
      let(:mock_config) { double(Helix::Config, build_url: :the_built_url, signature: :some_sig) }
      subject      { obj.method(meth) }
      let(:params) { { params: {signature: :some_sig } } }
      before do
        obj.stub(:config)            { mock_config }
        obj.stub(:guid)              { :some_guid  }
        obj.stub(:plural_resource_label) { :resource_label }
        RestClient.stub(:get) { '' }
      end
      { '' => '', mp3: :mp3, nil => '' }.each do |arg,actual|
        build_url_h = {action: :play, content_type: actual, guid: :some_guid, resource_label: :resource_label}
        context "when given {content_type: #{arg}" do
          it "should build_url(#{build_url_h})" do
            mock_config.should_receive(:build_url).with(build_url_h)
            obj.send(meth, content_type: arg)
          end
          it "should get a view signature" do
            mock_config.should_receive(:signature).with(:view) { :some_sig }
            obj.send(meth, content_type: arg)
          end
          it "should return an HTTP get to the built URL with the view sig" do
            mock_config.stub(:build_url).with(build_url_h) { :the_url }
            RestClient.should_receive(:get).with(:the_url, params) { :expected }
            expect(obj.send(meth, content_type: arg)).to be(:expected)
          end
        end
      end
    end

  end

  ### CLASS METHODS

  it_behaves_like "ingest_sig_opts", Helix::Track
  it_behaves_like "uploads",         Helix::Track

end
