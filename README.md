# The Ruby Toolbox

[![Build Status](https://travis-ci.org/rubytoolbox/rubytoolbox.svg?branch=master)](https://travis-ci.org/rubytoolbox/rubytoolbox)

As I was focusing on [getting the new site ready for relaunch](https://www.ruby-toolbox.com/blog/2018-02-01/lets-push-things-forward), development setup documentation got postponed. Pending [#82](https://github.com/rubytoolbox/rubytoolbox/issues/82), development documentation will be added here very soon! Thanks for your patience! 

#### Prerequisites

##### Postgresql

Using OS-X:

    $ brew install postgresql

##### Ruby

Using [RVM](https://rvm.io/rubies/installing)

    $ rvm install 2.5.0
    
Using [RBEnv](https://github.com/rbenv/rbenv#installing-ruby-versions)

    $ rbenv install 2.5.0 

##### Yarn (https://yarnpkg.com/en/docs/install)            
See [YARN](https://yarnpkg.com/en/docs/install)

Short version for OS-X:

    $ brew install yarn

#### Installation

    $ gem install bundler
    $ bundle install
    $ rake db:setup
    $ rake db:migrate
    $ rake yarn:install
    
