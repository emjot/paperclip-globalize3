# Paperclip::Globalize3

# Travanto [![Tests](https://github.com/emjot/paperclip-globalize3/actions/workflows/test.yml/badge.svg)](https://github.com/emjot/paperclip-globalize3/actions/workflows/test.yml)

Use locale-specific attachments in your Rails app with [paperclip](https://github.com/thoughtbot/paperclip) and
[globalize](https://github.com/globalize/globalize).

You can transparently read and write your attachments in context of the current locale. E.g. `my_model.my_attachment` returns a different attachment when your current locale is 'en' compared to when your current locale is 'de'.

Note that this implementation patches some methods in the `Paperclip::Attachment` class, so make sure you are okay with that.

## Compatibility

* paperclip 5.3 - 6.1
* globalize 5.3
* Rails 4.2/5.0/5.1/5.2/6.0

Rails 5.2 and later are only tested with paperclip 6.1 (see `.travis.yml` for details).

For support of previous paperclip / globalize / rails versions please refer to the 3.x versions of this gem.

## Maintainance State of This Gem

Since paperclip itself has been [deprecated](https://thoughtbot.com/blog/closing-the-trombone) and we currently do not use this gem in active projects any more, further development of this gem (e.g. compatibility with Rails 6.1) is unlikely. If anyone wants to submit a PR, we will of course still try to review + merge. 

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
      validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
      translates :avatar_file_name, :avatar_file_size, :avatar_created_at, :avatar_updated_at, :avatar_fingerprint
    end

## Development

### Testing

To setup tests, make sure all the ruby versions defined in `.travis.yml` are installed on your system.

Run tests via:

* `rake wwtd` for all combinations of ruby/rails/paperclip versions (NOTE that when using `rake wwtd:parallel` there
   might be some flickering test failures - needs to be investigated)
* `rake wwtd:local` for all rails/paperclip versions, but only on current ruby
* `rake spec` (or e.g. `bundle exec rspec spec --format documentation`) with main Gemfile and only on current ruby

### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
