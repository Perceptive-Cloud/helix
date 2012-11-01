require './video.rb'
GUID = '06c25e44f988c'

v = Video.find(GUID)
['before AR', 'updated via AR'].each do |desired_title|
  v.put(:update_single_field, { field: 'title', value: desired_title })
  v.reload
  puts "Video #{GUID} title is '#{v.title}'"
end
