# Paperclip::Globalize3

[![Build Status](https://travis-ci.org/emjot/paperclip-globalize3.png?branch=master)](https://travis-ci.org/emjot/paperclip-globalize3)

Use locale-specific attachments in your Rails app with paperclip and globalize3.

You can transparently read and write your attachments in context of the current locale. E.g. `my_model.my_attachment` returns a different attachment when your current locale is 'en' compared to when your current locale is 'de'.

Note that this implementation patches some methods in the `Paperclip::Attachment` class, so make sure you are okay with that.

## Compatibility

Currently, paperclip 2.x (>= 2.5) and globalize3 0.3 are supported. Support for paperclip 3.x is planned.

## Installation

Add this line to your application's Gemfile:

    gem 'paperclip-globalize3'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install paperclip-globalize3

## Usage

For each of your attachments which should have support for different locales, set up the following:

1. Migrate the paperclip columns ('xxx_file_name' etc.) of the attachment to the translation table
2. Declare in the model that it 'translates' the paperclip fields ('xxx_file_name' etc.)
3. Use the :locale interpolation for the paperclip url

NOTE: Make sure your `translates` are always defined after the `has_attached_file`! (Otherwise the files will not be deleted from the filesystem when the model is destroyed.)

Example:

    class User < ActiveRecord::Base
      has_attached_file :avatar,
                        :url => "/system/:attachment/:id/:locale/:style-:fingerprint.:extension"
      translates :avatar_file_name, :avatar_file_size, :avatar_created_at, :avatar_updated_at, :avatar_fingerprint
    end

## Todo / Future Plans

* Support paperclip 3.x
* Make it easier to specify translated attachments, e.g. using one of these options:
  * support `translates :attachment_name`
  * support `:translated` option for `has_attached_file`
  * eliminate the need to specify; automatically set `translates` as soon as the :locale interpolation is used
* Don't depend on order of definition for it to work (`translates` after `has_attached_file`)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
