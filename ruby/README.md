# PIGG Ruby

This is a Ruby version of the Perl script for PIGG Automation described in Step 3 at https://modjeska.us/diy-image-gallery/.

This does not generate the HTML page. If anyone needs that, open an issue in this repo and I'll spend some time on it.

## Prerequisites

```
brew install imagemagick
gem install mini_magick
gem install rspec
```

## Run tests

```
cd /path/to/pigg/ruby
rspec
```

## Ruby script usage

```
cd /path/to/pigg/ruby
ruby pigg.rb /path/to/pigg/example-project-3/
```
