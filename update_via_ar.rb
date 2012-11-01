require './video.rb'
FILENAME = './helix.yml'
GUID     = YAML.load(File.open(FILENAME))['video_id']

v = Video.find(GUID)
v.put(:update_single_field, { field: 'title', value: 'before AR update' })
v.reload
puts "Video #{GUID} title is '#{v.title}'"
v.put(:update_single_field, { field: 'title', value: 'updated via AR' })
v.reload
puts "Video #{GUID} title is now '#{v.title}'"
v.put(:update_single_field, { field: 'title', value: 'updated after AR' })
v.reload
puts "Video #{GUID} title is now '#{v.title}'"
