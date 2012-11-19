require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::Video do

  def import_xml
    { list: { entry: {} } }.to_xml(root: :add)
  end

  let(:klass) { Helix::Video }

  subject { klass }
  its(:ancestors)         { should include(Helix::Base) }
  its(:guid_name)         { should eq('video_id') }
  its(:media_type_sym)    { should be(:video)   }
  its(:plural_media_type) { should eq('videos') }

  describe "Constants"

  describe "an instance" do
    let(:obj) { klass.new({'video_id' => 'some_video_guid'}) }
    subject { obj }
    its(:media_type_sym) { should be(:video) }
  end

  describe ".import" do
    let(:meth)        { :import }
    let(:mock_config) { mock(Helix::Config) }
    subject           { klass.method(meth) }
    its(:arity)       { should eq(-1) }
    let(:klass_sym)   { :klass }
    let(:resp_json)   { :json }
    let(:sig)         { :some_sig }
    let(:resp_value)  { { klass:        { attributes: nil } } }
    let(:params)      { { params:       { signature: :some_sig } } }  
    let(:sig_opts)    { { contributor:  :helix, 
                          library_id:   :development } }
    let(:build_opts)  { { action:       :create_many, 
                          media_type:   :klasses, 
                          format:       :xml } }
    let(:xml)         { import_xml }
    before do
      klass.stub(:plural_media_type)                { :klasses  }
      klass.stub(:media_type_sym)                   { klass_sym }
      mock_config.stub(:build_url).with(build_opts) { :url }
      mock_config.stub(:signature).with(:ingest)    { :some_sig }
      Helix::Config.stub(:instance)                 { mock_config }
    end
    it "should get an ingest signature" do
      mock_config.should_receive(:build_url).with(build_opts)
      mock_config.should_receive(:signature).with(:ingest, sig_opts)  { :some_sig }
      RestClient.should_receive(:post).with(:url, import_xml, params) { resp_json }
      Hash.should_receive(:from_xml).with(resp_json)                  { resp_value }
      klass.should_receive(:new).with(resp_value[klass_sym].merge(config: mock_config))
      klass.send(meth)
    end
  end

end
