require 'rubygems'
require 'helix'

# VARIOUS ALLELES

# Defer media type until the method call
api = Helix::API.authenticate(license_key, opts)
api.search_videos(opts)

# Establish media type early, in instantiation
api = Helix::VideoAPI.authenticate(license_key, opts)
api.search(opts)

# Other sample calls
api.update_playlist(the_guid, title: 'some new title')
api.create_asset(video_guid, format: 'ogv') # automatically works out that it's for a video from
# the guid or from a @media_type within the api instance, if defined as a VideoApi, for example

# The following would presumably be equivalent
api.create_playlist(title: 'x', media_type: 'video', description: 'xx')
api.create_video_playlist(title: 'x', description: 'xx')

# As would these. The 2nd example with the block is more like an XML builder and other similar code.
api.create_library(name: 'xx', hooks_attributes: some_opts_hash)
api.create_library do |lib|
  lib.name = 'xx'
  lib.hooks_attributes = some_opts_hash
end

