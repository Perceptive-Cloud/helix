http://nestacms.com/docs/creating-content/markdown-cheat-sheet
http://support.mashery.com/docs/customizing_your_portal/Markdown_Cheat_Sheet

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

Supported Ruby versions
-----------------------

1.9.3

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
Required fields for create: 
#####title, description, library, company, and source.
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
Required fields for create: 
#####title, library, company.
```ruby
album = Helix::Album.create!( title:       'New Album', 
                              description: 'A album of new things', 
                              source:      'http://somesource.com/source.mp4'
                              company:     'some_company',
                              library:     'some_library')
album.update({title: "New Title"})
another_album = Helix::Album.find(some_guid)
another_album.destroy
```
###Images
Required fields for create: 
#####title, library, company.
```ruby
album = Helix::Album.create!( title:       'New Album', 
                              description: 'A album of new things', 
                              source:      'http://somesource.com/source.mp4'
                              company:     'some_company',
                              library:     'some_library')
album.update({title: "New Title"})
another_album = Helix::Album.find(some_guid)
another_album.destroy
```
###Tracks
Required fields for create: 
#####title, library, company.
```ruby
album = Helix::Album.create!( title:       'New Album', 
                              description: 'A album of new things', 
                              source:      'http://somesource.com/source.mp4'
                              company:     'some_company',
                              library:     'some_library')
album.update({title: "New Title"})
another_album = Helix::Album.find(some_guid)
another_album.destroy
```
###Playlists
Required fields for create: 
#####title, library, company.
```ruby
album = Helix::Album.create!( title:       'New Album', 
                              description: 'A album of new things', 
                              source:      'http://somesource.com/source.mp4'
                              company:     'some_company',
                              library:     'some_library')
album.update({title: "New Title"})
another_album = Helix::Album.find(some_guid)
another_album.destroy
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

Helix was written by Kevin Baird and Michael Wood with contributions from several authors, including:

* Other
* People

Helix is maintained and funded by [Twistage, inc](http://twistage.com)

The names and logos for twistage are trademarks of twistage, inc.

License
-------

Helix is Copyright © 2008-2012 Twistage, inc.