# The Ruby Toolbox

[![Build Status](https://travis-ci.org/rubytoolbox/rubytoolbox.svg?branch=master)](https://travis-ci.org/rubytoolbox/rubytoolbox)
[![Depfu](https://badges.depfu.com/badges/84ab24dbd83e15c8dfd36144e10d14f2/overview.svg)](https://depfu.com/github/rubytoolbox/rubytoolbox)

As I was focusing on [getting the new site ready for relaunch](https://www.ruby-toolbox.com/blog/2018-02-01/lets-push-things-forward),
development setup documentation got postponed. Pending [#82](https://github.com/rubytoolbox/rubytoolbox/issues/82), development documentation will be added here very soon! Thanks for your patience!

### Prerequisites

Ruby-toolbox depends on a few external services which you will need to install before you begin.

#### Upgrading your system dependency manager

Linux with [Yum](https://en.wikipedia.org/wiki/Yellow_Dog_Updater,_Modified)-based package management:

    [root@ip-1.3.3.7 ~]# yum update
    Loaded plugins: priorities, update-motd, upgrade-helper
    ...
    Complete!
    [root@ip-1.3.3.7 ~]#

Linux with [Apt](https://en.wikipedia.org/wiki/APT_(Debian))-based package management:

    admin@ip-1-3-3-7:~$ sudo apt-get update
    Ign http://cloudfront.debian.net jessie InRelease
    ...
    Fetched 15.3 MB in 3s (4,634 kB/s)
    Reading package lists... Done
    admin@ip-1.3.3.7:~$

OS-X with [Homebrew](https://brew.sh/):

    (user@1.3.3.7 ~)$brew update
    Updated 3 taps (homebrew/core, caskroom/versions, caskroom/cask).
    ==> New Formulae
    ...
    ==> Updated Formulae
    ...
    (user@1.3.3.7 ~)

#### Installing Postgresql

**Linux:** Use the official package postgres repositories for

* [Apt](https://wiki.postgresql.org/wiki/Apt) - see [How to install and use postgreaql on ubuntu 16.04](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-ubuntu-16-04) for examples

* [Yum](https://yum.postgresql.org/) - see [How to install and use postgresql on CentOS 7](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-centos-7) for exmaples

**OS-X:**

* [HomeBrew](http://brewformulas.org/Postgresql) - see [How to install PostgreSQL on a Mac](https://www.moncefbelyamani.com/how-to-install-postgresql-on-a-mac-with-homebrew-and-lunchy/) for examples

#### Installing REDIS

**APT**

If you want to use a prebuilt package, we recommend you use one from [This PPA](https://launchpad.net/%7Echris-lea/+archive/ubuntu/redis-server).
Otherwise build from source as detailed in [The REDIS quickstart](https://redis.io/topics/quickstart)

**YUM etc**

There is no easy mode for this, you will need to build it from source.  See [The REDIS quickstart](https://redis.io/topics/quickstart)

#### Ruby

Install the [current project ruby version](./.ruby-version), preferably with
[a Ruby version manager like chruby, rbenv, or rvm](https://www.ruby-toolbox.com/categories/ruby_version_management)

#### YARN

Yarn is used to manage javascript dependencies necessary to build the javascript assets for the project.

YARN can be installed by following [the official installation guide](https://yarnpkg.com/lang/en/docs/install/)

#### Configuring the ruby-toolbox application

1. Start Postgresql
2. Start REDIS
2. Install Bundler and gem dependencies
```
$ gem install bundler
$ bundle install
```
3. Create the database schema
```
$ rake db:setup
$ rake db:migrate
```
4. Install and configure YARN into the project
```
$ rake yarn:install
```
5. Start ruby-toolbox
```
   (user@1.3.3.7 ~/private/ruby/opensource/rubytoolbox)$puma -e development
   Puma starting in single mode...
   * Version 3.11.2 (ruby 2.5.0-p0), codename: Love Song
   * Min threads: 5, max threads: 5
   * Environment: development
   * Listening on tcp://0.0.0.0:3000
```

