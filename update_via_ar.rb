require './video.rb'
GUID = '06c25e44f988c'

v = Video.find(GUID)
v.put(:update_single_field, { field: 'title', value: 'myria (before AR update)' })
v.reload
puts "Video #{GUID} title is '#{v.title}'"
v.put(:update_single_field, { field: 'title', value: 'myria-updated via AR' })
v.reload
puts "Video #{GUID} title is now '#{v.title}'"
v.put(:update_single_field, { field: 'title', value: 'myria-updated after AR' })
v.reload
puts "Video #{GUID} title is now '#{v.title}'"
