require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::Video do

  def import_xml(values={})
    { list: { entry: values[:url_params] || {} } }.to_xml(root: :add)
  end

  let(:klass)             { Helix::Video }
  subject                 { klass }
  its(:guid_name)         { should eq('video_id') }
  its(:media_type_sym)    { should be(:video)   }
  its(:plural_media_type) { should eq('videos') }

  describe "Constants"

  describe "an instance" do
    let(:obj)            { klass.new({'video_id' => 'some_video_guid'}) }
    subject              { obj }
    its(:media_type_sym) { should be(:video) }
  end

  describe ".slice" do
    let(:meth)        { :slice }
    let(:mock_config) { mock(Helix::Config) }
    subject           { klass.method(meth) }
    its(:arity)       { should eq(-1) }
    let(:params)      { { params: { signature: :some_sig } } }
    let(:url_opts)    { { action:       :slice,
                          media_type:   "videos",
                          content_type: :xml,
                          formats:      :some_format } }
    let(:sig_opts)    { { contributor:  :helix,
                          library_id:   :development,
                          formats:      :some_format } }
    before            { Helix::Config.stub(:instance) { mock_config } }

    it "should get an ingest signature" do
      mock_config.should_receive(:build_url).with(url_opts)
      mock_config.should_receive(:signature).with(:ingest, sig_opts) { :some_sig }
      RestClient.should_receive(:post).with(nil, import_xml, params)
      klass.send(meth, {formats: :some_format})
    end
  end
end
