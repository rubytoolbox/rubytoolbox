# The Ruby Toolbox

[![Build Status](https://travis-ci.org/rubytoolbox/rubytoolbox.svg?branch=master)](https://travis-ci.org/rubytoolbox/rubytoolbox)
[![Depfu](https://badges.depfu.com/badges/84ab24dbd83e15c8dfd36144e10d14f2/overview.svg)](https://depfu.com/github/rubytoolbox/rubytoolbox)

**Explore and compare open source Ruby libraries**

## Development

### Prerequisites

The Ruby Toolbox depends on a few external services which you will need to install before you begin.

#### [PostgreSQL](https://www.postgresql.org/)

**Linux:** Use the official postgres repositories for [Apt](https://wiki.postgresql.org/wiki/Apt) or [Yum](https://yum.postgresql.org/)

**OS-X:**

* [HomeBrew](http://brewformulas.org/Postgresql) - see [How to install PostgreSQL on a Mac](https://www.moncefbelyamani.com/how-to-install-postgresql-on-a-mac-with-homebrew-and-lunchy/) for examples
* [Postgres.app](https://postgresapp.com/)

#### [Redis](https://redis.io/)

**APT**

If you want to use a prebuilt package, we recommend you use one from [This PPA](https://launchpad.net/%7Echris-lea/+archive/ubuntu/redis-server).
Otherwise build from source as detailed in [The Redis quickstart](https://redis.io/topics/quickstart)

**YUM etc**

There is no easy mode for this, you will need to build it from source.  See [The Redis quickstart](https://redis.io/topics/quickstart)

#### Ruby

Install the [current project ruby version](./.ruby-version), preferrably with
[a Ruby version manager like chruby, rbenv, or rvm](https://www.ruby-toolbox.com/categories/ruby_version_management)

You will also need [Bundler](http://bundler.io/) for installing the project's dependencies.

#### Yarn

Yarn is used to manage javascript dependencies necessary to build the javascript assets for the project.

YARN can be installed by following [the official installation guide](https://yarnpkg.com/lang/en/docs/install/)

#### Running the application

1. Start postgres and redis
1. Install the project's dependencies by running `bundle install`
1. Prepare the database with `rake db:setup`
1. Install the frontend dependencies using `yarn install`
1. Run the services with `foreman start`. You can access the site at `http://localhost:5000`

**Further steps:**

* You can run the test suite with `bundle exec rspec`
* You can check the code with `bundle exec rubocop`
* During development you can launch [guard](https://github.com/guard/guard) using `bundle exec guard` to continuously check changes
* The repo has [overcommit](https://github.com/brigade/overcommit) git hooks set up to check your changes before commit, push etc. You can set it up once with `bundle exec overcommit --install`. Whenever the hook config file `.overcommit.yml` changes, you need to verify it's contents and approve the changes with `bundle exec overcommit --sign`

## Code of Conduct

Everyone participating in this project's development, issue trackers and other channels is expected to follow our [Code of Conduct](./CODE_OF_CONDUCT.md)

## License

This project is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
