require 'rubygems'
require 'helix'

# MORE IDEAS FROM KEVIN

Helix::Playlist.create!(title: 'x', description: 'xx', media_type: 'video', yaml_file: 'some_other_file.yml')

Helix::Playlist.create!(title: 'x', description: 'xx', media_type: 'video', license_key: 'some_key_different_from_what_is_in_the_yaml_file')

p = Helix::Playlist.authenticate(yaml_file: 'some_file.yml')
# (method name could be authenticate, scope, attach, connect, etc.)
p.create!(title: 'x', description: 'xx', media_type: 'video')

h = Helix::API.create # no args, reads YAML config from default location
h = Helix::API.create(license_key: 'blah') # override specific key in the YAML
h = Helix::API.create(yaml_file: 'some_file.yml') # override location of YAML file
h.playlists.create!(...)
h.videos.complete.since(2.weeks.ago).per_page(3).offset(7).to_json
# same as
api.search_videos(status: 'complete', since: '2 weeks ago', per_page: 3, offset: 7, format: 'json')

