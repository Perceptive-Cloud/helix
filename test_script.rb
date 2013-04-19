require 'helix'

config = Helix::Config.load('./helix.yml')

media_by_id = {
  album_id: Helix::Album,
  image_id: Helix::Image,
  track_id: Helix::Track,
  video_id: Helix::Video
}
media_by_id.each do |guid_key,klass|

  items = klass.all
  puts "#{klass.to_s}.all returns #{items.size} items"

  items = klass.find_all(query: 'rest-client')
  puts "Searching #{klass.to_s} on query => 'rest-client' returns #{items}"

  media_id = config.credentials[guid_key]
  next if media_id.nil?
  items = klass.find_all(query: media_id)
  puts "Searching #{klass.to_s} on query => '#{media_id}' returns #{items}"
  item = klass.find(media_id)
  puts "Read #{klass.to_s} from guid #{media_id}: #{item.inspect}"

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
