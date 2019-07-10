# (unreleased)

* Breaking changes 
    * Drop support for ruby < 2.4.6
    * Drop support for globalize < 5.3   
* Bugfixes
    * Fix `attachment.clear(:style)` not deleting the files ([#17](https://github.com/emjot/paperclip-globalize3/pull/17)) 
* Enhancements
    * Allow globalize 5.3
      With globalize 5.3.0 paperclip-globalize3 is again compatible witj Rails 4.2 

# 3.3.0 (2019-05-14)

* Enhancements
    * Allow globalize 5.2 ([#14](https://github.com/emjot/paperclip-globalize3/pull/14)). 
      Note that globalize 5.2.0 is currently broken in rails 4.2; see README. 

# 3.2.0 (2019-04-18)

* Enhancements
    * Allow paperclip 6.1 ([#13](https://github.com/emjot/paperclip-globalize3/pull/13))

# 3.1.0 (2019-04-15)

* Enhancements
    * Support for paperclip 6.0.0 ([#12](https://github.com/emjot/paperclip-globalize3/pull/12))
* Internal / development
    * update ruby patch versions

# 3.0.0 (2018-02-07)

* Breaking changes 
    * Drop support for ruby < 2.2.2
    * Drop support for rails < 4.2
    * Drop support for paperclip < 4.2
    * Drop support for globalize < 5.0
    * Move paperclip-globalize3.rb to paperclip/globalize3.rb 
      (if you manually require 'paperclip-globalize3', change it to 'paperclip/globalize3')
* Bugfixes
    * (none)
* Enhancements
    * Support ruby 2.3 and 2.4
    * Test with paperclip 4.3
    * Support paperclip 5.0/5.1/5.2
    * Support rails 5.1
* Internal / development
    * Bump dependencies 
    * Add rubocop
    * Add yard

# 2.x and before

(Sorry, there was no CHANGELOG before, so please refer to github commits.)
