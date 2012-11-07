http://nestacms.com/docs/creating-content/markdown-cheat-sheet
http://support.mashery.com/docs/customizing_your_portal/Markdown_Cheat_Sheet

# Helix

The Helix gem allows developers to easily connect to and manipulate the Twistage API.

TODO
----

* List 
* Of 
* TODO

Documentation
-------------

You should find the documentation for your version of helix on [Rubygems](https://rubygems.org/gems/helix).

How To
------
Example CRUD.
###Setup YAML
```yaml
site: 'http://service.twistage.com'
user: 'my_account@twistage.com'
password: 'password123'
company: 'my_company'
license_key: '141a86b5c4091
```
####Current CRUD methods supported by all models
.create
.find
\#update
\#destroy

####Current models
Videos, Images, Albums, Tracks, Playlists

###Videos
Example CRUD operations with video model.
```ruby
video = Helix::Video.create!( title:       'New Video', 
                              description: 'A video of new things', 
                              source:      'http://somesource.com/source.mp4')
video.update({title: "New Title"})
another_video = Helix::Video.find(some_guid)
another_video.destroy
```

```ruby
Helix::Video.update
Helix::Video.find(GUID)
```

###Albums
###Images
###Tracks
###Playlists
```ruby
Helix::Playlist.create!(title:        'x', 
                        description:  'xx', 
                        media_type:   'video', 
                        yaml_file:    'some_other_file.yml')

Helix::Playlist.create!(title:        'x', 
                        description:  'xx', 
                        media_type:   'video', 
                        license_key:  'some_key_different_from_what_is_in_the_yaml_file')

playlist = Helix::Playlist.authenticate(yaml_file: 'some_file.yml')
# (method name could be authenticate, scope, attach, connect, etc.)
playlist.create!(title: 'x', description: 'xx', media_type: 'video')

api = Helix::API.create # no args, reads YAML config from default location
api = Helix::API.create(license_key: 'blah') # override specific key in the YAML
apo = Helix::API.create(yaml_file: 'some_file.yml') # override location of YAML file
```

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

Supported Ruby versions
-----------------------

1.9.3

More Information
----------------

* [Rubygems](https://rubygems.org/gems/helix)
* [Issues](https://github.com/twistage/helix/issues)

Contributing
------------

How to contribute

Credits
-------

Helix was written by Kevin Baird and Michael Wood with contributions from several authors, including:

* Other
* People

Helix is maintained and funded by [Twistage, inc](http://twistage.com)

The names and logos for twistage are trademarks of twistage, inc.

License
-------

Helix is Copyright © 2008-2012 Twistage, inc.