require './video.rb'
GUID = 'bc3f6246c3ed2'

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
