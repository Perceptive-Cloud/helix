require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::Video do

  def import_xml(values={})
    { list: { entry: values[:url_params] || {} } }.to_xml(root: :add)
  end

  klass = Helix::Video
  subject { klass }
  mods = [ Helix::Base, Helix::Durationed, Helix::Media ]
  mods.each { |mod| its(:ancestors) { should include(mod) } }
  its(:guid_name)             { should eq('video_id') }
  its(:resource_label_sym)    { should be(:video)     }
  its(:plural_resource_label) { should eq('videos')   }
  [:find, :create, :all, :find_all, :where].each do |crud_call|
    it { should respond_to(crud_call) }
  end

  describe "Constants"

  ### INSTANCE METHODS

  describe "an instance" do
    obj = klass.new({video_id: 'some_video_guid'})
    subject   { obj }
    its(:resource_label_sym) { should be(:video) }

    it_behaves_like "downloads", obj
    it_behaves_like "plays",     obj

    describe "#stillframe" do
      let(:meth)        { :stillframe }
      let(:mock_config) { double(Helix::Config) }
      subject           { obj.method(meth) }
      its(:arity)       { should eq(-1) }
      it "should call self.class.get_stillframe" do
        obj.stub(:guid) { :some_guid }
        klass.should_receive(:stillframe_for)
        obj.send(meth)
      end
    end

    describe "serialization" do
      let(:mock_attributes) {
        {
          "created_at"=>"2013-04-09 16:33:58 UTC",
          "description"=>"description of updated via rest-client",
          "hidden"=>false,
          "publisher_name"=>"kbaird@twistage.com",
          "title"=>"updated via rest-client",
          "video_id"=>"ece0d3fd03bf0",
          "status"=>"available",
          "contributor"=>"kbaird@twistage.com",
          "site_name"=>"11701",
          "library_name"=>"11701",
          "main_asset_url"=>"http://service-staging.twistage.com/videos/ece0d3fd03bf0/assets/438894/file.flv",
          "source_asset_url"=>"http://service-staging.twistage.com/videos/ece0d3fd03bf0/assets/438893/file.mp4",
          "hits_count"=>0,
          "plays_count"=>0,
          "duration"=>255.791,
          "total_size"=>158410133,
          "availability"=>"available",
          "main_asset_id"=>438894,
          "progress"=>100,
          "artist"=>"",
          "genre"=>"",
          "assets"=>[
            {"id"=>438893, "size"=>140035687, "status_code"=>30, "acodec"=>"er aac ld", "audio_bitrate"=>128, "container"=>"mp4",
              "download_url"=>"http://service-staging.twistage.com/videos/ece0d3fd03bf0/assets/438893/file.mp4", "duration"=>255.84,
              "frame_rate"=>25.0, "hresolution"=>1280, "is_main_asset"=>false, "vcodec"=>"avc1", "video_bitrate"=>4247,
              "video_format_name"=>"source", "vresolution"=>720, "status"=>"complete", "detailed_status"=>nil},
            {"id"=>438894, "size"=>18374446, "status_code"=>30, "acodec"=>"mp3", "audio_bitrate"=>67, "container"=>"flv",
              "download_url"=>"http://service-staging.twistage.com/videos/ece0d3fd03bf0/assets/438894/file.flv", "duration"=>255.791,
              "frame_rate"=>25.0039099155, "hresolution"=>480, "is_main_asset"=>true, "vcodec"=>"h263", "video_bitrate"=>487,
              "video_format_name"=>"flash-low", "vresolution"=>270, "status"=>"complete", "detailed_status"=>nil}
          ],
          "screenshots"=>[
            {"frame"=>141.4, "content_type"=>"image/jpeg", "width"=>1280, "height"=>720, "size"=>260548,
              "url"=>"http://service-staging.twistage.com:80/videos/ece0d3fd03bf0/screenshots/original.jpg"}
          ],
          "tags"=>[],
          "custom_fields"=>[{"name"=>"blaaagghhh", "value"=>""}, {"name"=>"videoCF", "value"=>""}]
        }
      }
      before(:each) do obj.instance_variable_set(:@attributes, mock_attributes) end

      describe "#to_json" do
        let(:meth) { :to_json }
        context "arity" do
          subject     { obj.method(meth) }
          its(:arity) { should eq(0) }
        end
        subject { obj.send(meth) }
        it { should eq({video: mock_attributes}.to_json) }
      end

      describe "#to_xml" do
        let(:meth) { :to_xml }
        context "arity" do
          subject     { obj.method(meth) }
          its(:arity) { should eq(0) }
        end
        subject { obj.send(meth) }
        let(:modified_attributes) {
          custom_fields = mock_attributes['custom_fields']
          new_cfs = custom_fields.inject({}) do |memo,cf|
            memo.merge(cf['name'] => cf['value'])
          end
          mock_attributes.merge('custom_fields' => new_cfs)
        }
        it { should eq(modified_attributes.to_xml(root: :video)) }
      end

    end

    [:destroy, :update].each do |crud_call|
      it { should respond_to(crud_call) }
    end

  end

  ### CLASS METHODS

  it_behaves_like "ingest_sig_opts", Helix::Video
  it_behaves_like "uploads",         Helix::Video

  describe ".slice" do
    let(:meth)        { :slice }
    let(:mock_config) { double(Helix::Config) }
    subject           { klass.method(meth) }
    its(:arity)       { should eq(-1) }
    let(:params)      { { params:       { signature: :some_sig },
                          content_type: "text/xml" } }
    let(:url_opts)    { { action:         :slice,
                          resource_label: "videos",
                          content_type:   :xml,
                          formats:        :some_format } }
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

  describe ".stillframe_for" do
    let(:meth)        { :stillframe_for }
    let(:mock_config) { double(Helix::Config) }
    subject           { klass.method(meth) }
    its(:arity)       { should eq(-2) }
    let(:image_data)  { :some_image_data }
    let(:guid)        { :some_guid }
    let(:server)      { "service-staging" }
    let(:base_url)    { "#{server}.twistage.com/videos/#{guid}/screenshots/" }
    context "when no height or width is passed in " do
      let(:full_url) { "#{base_url}original.jpg" }
      it "should build the correct url and return data" do
        RestClient.should_receive(:get).with(full_url) { image_data }
        expect(klass.send(meth, guid)).to eq(image_data)
      end
    end
    [:height, :width].each do |dimension|
      context "when #{dimension} is passed in" do
        url_tag = (dimension == :height ? "h" : "w")
        let(:dim_val)   { 100 }
        let(:full_url)  { "#{base_url}#{dim_val}#{url_tag}.jpg" }
        let(:opts)      { { dimension => dim_val } }
        it "should clone the opts arg" do
          RestClient.stub(:get).with(full_url) { image_data }
          opts.should_receive(:clone) { opts }
          klass.send(meth, guid, opts)
        end
        it "should build the correct url and return data" do
          RestClient.should_receive(:get).with(full_url) { image_data }
          expect(klass.send(meth, guid, opts)).to eq(image_data)
        end
      end
    end
    context "when both height and width are passed in" do
      let(:dim_val)   { 100 }
      let(:full_url)  { "#{base_url}#{dim_val}w#{dim_val}h.jpg" }
      let(:opts)      { { height: dim_val, width: dim_val } }
      it "should clone the opts arg" do
        RestClient.stub(:get).with(full_url) { image_data }
        opts.should_receive(:clone) { opts }
        klass.send(meth, guid, opts)
      end
      it "should build the correct url and return data" do
        RestClient.should_receive(:get).with(full_url) { image_data }
        expect(klass.send(meth, guid, opts)).to eq(image_data)
      end
    end
  end
end
