# Helix

The Helix gem allows developers to easily connect to and manipulate the Twistage API.

Documentation
-------------

You should find the documentation for your version of helix on [Rubygems](https://rubygems.org/gems/helix).

Install
--------

```shell
gem install helix
```
or add the following line to Gemfile:

```ruby
gem 'helix'
```
and run `bundle install` from your shell.

Install From Repo
-----------------
Using sudo:
```shell
git clone git@github.com:Twistage/helix.git 
gem build helix.gemspec  
sudo gem i helix-*.gem
```

RVM or root support:
```shell
git clone git@github.com:Twistage/helix.git
gem build helix.gemspec
gem i helix-*.gem
```

Rebuilding the gem, use the first for sudo, the second for RVM or root:
```shell
rake reinstall_helix
rake reinstall_helix_rvm
```

Using gem in a Gemfile  
```shell
gem 'helix', :git => git@github.com:Twistage/helix.git
```



Supported Ruby versions
-----------------------

1.9.3  
1.9.2  

How To
------
Warning: How To is not currently finished, it may be inaccurate. 
###Setup YAML
```yaml
site: 'http://service.twistage.com'
user: 'my_account@twistage.com'
password: 'password123'
company: 'my_company'
license_key: '141a86b5c4091
```
Load the YAML file as your config.
```ruby
Helix::Config.load("path/to/yaml.yml")
```
####Current CRUD methods supported by all models
.create  
.find  
\#update  
\#destroy  

####Current models
Videos, Images, Albums, Tracks, Playlists

###Videos
#####Required fields: title, description, library, company, and source.
```ruby
video = Helix::Video.create!( title:       'New Video', 
                              description: 'A video of new things', 
                              source:      'http://somesource.com/source.mp4'
                              company:     'some_company',
                              library:     'some_library')
video.update({title: "New Title"})
another_video = Helix::Video.find(some_guid)
another_video.destroy
```
###Albums
#####Required fields: title, library, company.
```ruby
album = Helix::Album.create!( title:       'New Album', 
                              description: 'A album of new things', 
                              source:      'http://somesource.com/source.mp4'
                              company:     'some_company',
                              library:     'some_library')
#Update for album is not currently supported
another_album = Helix::Album.find(some_guid)
another_album.destroy
```
###Images
#####Required fields: title, description, library, company, and source.
```ruby
image = Helix::Image.create!( title:       'New Image', 
                              description: 'A image of new things', 
                              source:      'http://somesource.com/source.jpg'
                              company:     'some_company',
                              library:     'some_library')
image.update({title: "New Title"})
another_image = Helix::Image.find(some_guid)
another_image.destroy
```
###Tracks
#####Required fields: title, description, library, company, and source.
```ruby
track = Helix::Track.create!( title:       'New Track', 
                              description: 'A track of new things', 
                              source:      'http://somesource.com/source.mp3'
                              company:     'some_company',
                              library:     'some_library')
track.update({title: "New Title"})
another_track = Helix::Track.find(some_guid)
another_track.destroy
```
###Playlists
#####Required fields: title, library, company.
```ruby
playlist = Helix::Playlist.create!( title:       'New Playlist', 
                                    description: 'A playlist of new things', 
                                    source:      'http://somesource.com/source.mp4'
                                    company:     'some_company',
                                    library:     'some_library')
playlist.update({title: "New Title"})
another_playlist = Helix::Playlist.find(some_guid)
another_playlist.destroy
```

More Information
----------------

* [Rubygems](https://rubygems.org/gems/helix)
* [Issues](https://github.com/twistage/helix/issues)

Contributing
------------

How to contribute

Credits
-------

Helix was written by Kevin Baird and Michael Wood.

Helix is maintained and funded by [Twistage, Inc](http://twistage.com)

The names and logos for twistage are trademarks of Twistage, Inc.

License
-------

Helix is Copyright © 2008-2012 Twistage, Inc.