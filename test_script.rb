require 'helix'

FILENAME = './helix.yml'
VIDEO_ID = YAML.load(File.open(FILENAME))['video_id']

media_by_id = {
  'track_id' => Helix::Track,
  'video_id' => Helix::Video
}
media_by_id.each do |guid_key,klass|

  items = klass.find_all(query: 'rest-client', status: :complete)
  puts "Searching #{klass.to_s} on query => 'rest-client' returns #{items}"

  media_id = YAML.load(File.open(FILENAME))[guid_key]
  item = klass.find(media_id)

  h = {
    # these keys are only available on the oobox branch
    #comments:    item.comments,
    #ratings:     item.ratings,
    screenshots: item.screenshots,
  }
  puts "#{klass.to_s} #{media_id} has #{h}"

  ['before rest-client', 'updated via rest-client' ].each do |desired_title|
    item.update(title: desired_title, description: "description of #{desired_title}")
    item.reload
    puts "#{klass.to_s} #{media_id} title is '#{item.title}'"
    puts "#{klass.to_s} #{media_id} description is '#{item.description}'"
  end
end
