require File.expand_path('../spec_helper', __FILE__)
require 'helix'

config_filename = File.expand_path('../../config/staging.yml', __FILE__)
config = Helix::Config.load(config_filename)
if config.nil?
  puts "No config, skipping integration specs"
  exit
end

media_by_id = {
  album_id:    Helix::Album,
  document_id: Helix::Document,
  image_id:    Helix::Image,
  track_id:    Helix::Track,
  video_id:    Helix::Video
}

media_by_id.each do |guid_key,klass|

  describe "Integration Specs for #{klass.to_s}" do

    #raise Helix::Config.instance.inspect

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
      subject { klass.find(media_id) }
      it { should_not be_empty }
      its(guid_key) { should eq(media_id) }
    end

=begin
    if guid_key == :video_id
      h = {
        # these keys are only available on the oobox branch
        #comments:    item.comments,
        #ratings:     item.ratings,
        screenshots: item.screenshots,
      }
      puts "#{klass.to_s} #{media_id} has #{h}"
      #puts item.download_url
      #puts item.play
    end

    next if guid_key == :album_id # No Update API yet

    ['before rest-client', 'updated via rest-client' ].each do |desired_title|
      item.update(title: desired_title, description: "description of #{desired_title}")
      item.reload
      puts "#{klass.to_s} #{media_id} title is '#{item.title}'"
      puts "#{klass.to_s} #{media_id} description is '#{item.description}'"
    end

    next if guid_key == :document_id # no Document stats yet

    media_type  = guid_key.to_s.split(/_/).first
    helix_stats = Helix::Statistics
    %w(delivery ingest storage).each do |stats_type|
      next if [:album_id, :image_id].include?(guid_key) and stats_type == 'ingest'
      next if [:image_id].include?(guid_key) and stats_type == 'delivery'
      stats = helix_stats.send("#{media_type}_#{stats_type}")
      puts "#{klass.to_s} #{stats_type} stats = #{stats.inspect}"
      item_stats = helix_stats.send("#{media_type}_#{stats_type}", guid_key => media_id)
      puts "#{klass.to_s} #{media_id} #{stats_type} stats = #{item_stats.inspect}"
    end

  end
=end
  end

end
