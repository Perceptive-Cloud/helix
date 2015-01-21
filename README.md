# Helix [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/Perceptive-Cloud/helix)

The Helix gem allows developers to easily connect to and manipulate the Perceptive Media API.

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
git clone git@github.com:Perceptive-Cloud/helix.git 
gem build helix.gemspec  
sudo gem i helix-*.gem
```

RVM or root support:
```shell
git clone git@github.com:Perceptive-Cloud/helix.git
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
gem 'helix', :git => 'git@github.com:Perceptive-Cloud/helix.git'
```


Supported Ruby versions
-----------------------

1.9.3  
1.9.2  

How To
------
###Setup YAML
```yaml
site: 'http://service.twistage.com'
company: 'my_company'
license_key: '141a86b5c4091'
library: 'development'
```
Boot up IRB in your console
```shell
irb
```
Load the YAML file as your config.
```ruby
require 'helix'
Helix::Config.load("path/to/yaml.yml")
videos = Helix::Video.find_all
```

If no file is passed in Helix with default to './helix.yml'


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

Helix is maintained and funded by [Perceptive Software](http://www.perceptivesoftware.com)

The names and logos for Perceptive Media are trademarks of Perceptive Software.

License
-------

Helix is Copyright © 2008-2014 Perceptive Software.
