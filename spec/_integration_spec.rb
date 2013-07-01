require File.expand_path('../spec_helper', __FILE__)
require 'helix'

config_filename = File.expand_path('../../config/staging.yml', __FILE__)
config = File.exists?(config_filename) ? Helix::Config.load(config_filename) : nil

if config.nil?

  puts "No config, skipping integration specs"

else

  media_by_id = {
    album_id:    Helix::Album,
    document_id: Helix::Document,
    image_id:    Helix::Image,
    track_id:    Helix::Track,
    video_id:    Helix::Video
  }

  media_by_id.each do |guid_key,klass|

    describe "Integration Specs for #{klass.to_s}" do

      describe ".all" do
        subject { klass.all }
        it { should_not be_empty }
      end

      describe ".where(query: 'rest-client')" do
        it "should not raise an exception" do
          lambda { klass.where(query: 'rest-client') }.should_not raise_error
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

      describe ".find(media_id)" do
        let(:item) { klass.find(media_id) }
        subject { item }
        it { should_not be_empty }
        its(guid_key) { should eq(media_id) }
        if guid_key == :video_id
          describe "screenshots" do
            expected_ss = {
              "frame"        => 141.4,
              "content_type" => "image/jpeg",
              "width"        => 1280,
              "height"       => 720,
              "size"         => 260548,
              "url"          => "http://edited-yet-again-staging.twistage.com:80/videos/ece0d3fd03bf0/screenshots/original.jpg"
            }
            subject { item.screenshots.first }
            it { should eq(expected_ss) }
          end
        end

      end

      unless guid_key == :document_id # no Document stats yet
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
