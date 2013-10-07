require File.expand_path('../spec_helper', __FILE__)
require 'helix'

config_filename = File.expand_path('../../config/staging.yml', __FILE__)
config = File.exists?(config_filename) ? Helix::Config.load_yaml_file(config_filename) : nil

if config.nil?
  puts "No config, skipping integration specs"
elsif %w(1 t true).include?(ENV['SKIP_INTEGRATION']) or not %w(1 t true).include?(ENV['INTEGRATION'])
  puts "Skipping integration specs due to user request"
else

  default_query_proc = lambda { |h,k| h[k] = 'rest-client' }
  query_by_guid_key  = Hash.new(&default_query_proc).merge(tag_id: '8143')

  resource_by_id = {
    album_id:    Helix::Album,
    document_id: Helix::Document,
    image_id:    Helix::Image,
    playlist_id: Helix::Playlist,
    tag_id:      Helix::Tag,
    track_id:    Helix::Track,
    video_id:    Helix::Video
  }

  resource_by_id.each do |guid_key,klass|

    describe "Integration Specs for #{klass.to_s}" do

      describe ".all" do
        subject { klass.all }
        it { should_not be_empty }
      end

      query = query_by_guid_key[guid_key]
      describe ".where(query: '#{query}')" do
        it "should not raise an exception" do
          lambda { klass.where(query: query) }.should_not raise_error
        end
        if guid_key == :tag_id
          subject { klass.where(query: query).first }
          it { should be_a Helix::Tag }
          its(:name)  { should be_a String  }
          its(:name)  { should eq '8143'    }
          its(:count) { should be_a Integer }
          its(:count) { should eq 2         }
        end
      end

      unless guid_key == :album_id
        describe ".where({custom_fields: {boole: 'true'}})" do
          it "should not raise an exception" do
            lambda { klass.where({custom_fields: {boole: 'true'}}) }.should_not raise_error
          end
        end
      end

      media_id = config.credentials[guid_key]
      next if media_id.nil?

      describe ".where(query: #{media_id}" do
        subject { klass.where(query: media_id) }
        it { should_not be_empty }
      end

      shared_examples_for "found #{klass}" do
        it { should_not be_nil }
        if klass == Helix::Playlist
          # Playlist Metadata is just a wrapper for an Array of media items: no guid
          its(guid_key) { should eq(nil) }
        else
          its(guid_key) { should eq(media_id) }
        end
        if guid_key == :video_id
          describe "screenshots" do
            expected_ss = {
              "frame"        => 141.4,
              "content_type" => "image/jpeg",
              "width"        => 1280,
              "height"       => 720,
              "size"         => 260548,
              "url"          => "http://service-staging.twistage.com:80/videos/ece0d3fd03bf0/screenshots/original.jpg"
            }
            subject { item.screenshots.first }
            it { should eq(expected_ss) }
          end
        end
      end

      describe ".find(media_id)" do
        let(:item) { klass.find(media_id) }
        subject { item }
        it_behaves_like "found #{klass}"
      end
      [ :json, :xml ].each do |content_type|
        describe ".find(media_id, content_type: #{content_type})" do
          let(:item) { klass.find(media_id, content_type: content_type) }
          subject { item }
          it_behaves_like "found #{klass}"
        end
      end

      unless [:document_id, :playlist_id, :tag_id].include?(guid_key) # no stats for these yet
        describe "Stats" do
          media_type  = guid_key.to_s.split(/_/).first
          helix_stats = Helix::Statistics
          %w(delivery ingest storage).each do |stats_type|
            next if [:album_id, :image_id].include?(guid_key) and stats_type == 'ingest'
            next if [:image_id].include?(guid_key) and stats_type == 'delivery'
            it "should call stats" do
              stats = helix_stats.send("#{media_type}_#{stats_type}")
              puts "#{klass.to_s} #{stats_type} stats = #{stats.inspect}"
              item_stats = helix_stats.send("#{media_type}_#{stats_type}", guid_key => media_id)
              puts "#{klass.to_s} #{media_id} #{stats_type} stats = #{item_stats.inspect}"
            end
          end
        end
      end

    end

  end

end
