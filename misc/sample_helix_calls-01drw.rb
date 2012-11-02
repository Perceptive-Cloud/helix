require 'rubygems'
require 'helix'

# DAVE'S IDEAS

# Playlist Create API
Helix::Playlist.create!(title: 'x', description: 'xx', media_type: 'video')

# Playlist Update API
p = Helix::Playlist.find_by_id(playlist_id)
# p is a Ruby object that offers methods like update!, destroy!, plus methods to get metadata
p.update!(title: 'some new title')
p.url
  (returns "http://service.twistage.com/playlists/ABCDE.rss")
p.url(limit: 2, format: json)
  (returns "http://service.twistage.com/playlists/ABCDE.json?limit=2")

# Asset Create API
v = Helix::Video.find_by_id(video_id)
v.create_asset!(format: 'ogv')
# or even
v.assets.create!(format: 'ogv')

# Video Search API
Helix::Video.find_all.each do |v|
  puts v.video_id
  (prints '123')
  v.download(directory: '/tmp')
  (uses specified output directory, with the default file name)
  v.download(file: 'myvideo.avi')
  (uses current working dir, with a specific file name)
end
Helix::Video.find_all(fields: 'video_id,title').each do |v|
  puts v.attributes
  (prints { 'video_id' => '123', 'title' => 'hello' })
end

# Library Update API
l = Helix::Library.find_by_id(library_id)
l.update!(:hooks_attributes => { :hook_notifier_attributes => { :type => :email, :email_template_attributes => { :email_from => "dwegman@twistage.com" }}})
# it might be nice to support higher-level wrappers for particularly cumbersome API calls, for example:
l.create_email_hook!(from: 'dwegman@twistage.com')

