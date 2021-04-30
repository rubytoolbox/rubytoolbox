<div align="center">
  <img src="./app/assets/images/logo/regular.svg" width="400px" alt="The Ruby Toolbox"/>

  [![CI](https://github.com/rubytoolbox/rubytoolbox/actions/workflows/ci.yml/badge.svg)](https://github.com/rubytoolbox/rubytoolbox/actions/workflows/ci.yml) [![Depfu](https://badges.depfu.com/badges/84ab24dbd83e15c8dfd36144e10d14f2/overview.svg)](https://depfu.com/github/rubytoolbox/rubytoolbox) [![This project is using Percy.io for visual regression testing.](https://percy.io/static/images/percy-badge.svg)](https://percy.io/rubytoolbox/rubytoolbox)

  **Find actively maintained & popular open source software libraries for the Ruby programming language**
</div>

The Ruby Toolbox is a catalog of all Rubygems that keeps track of popularity and health metrics to help you choose a reliable library.

**This is the source code for the site you can visit at https://www.ruby-toolbox.com/**

## Development

### Prerequisites

The Ruby Toolbox depends on a few utilities which you will need to install before you begin.

#### [PostgreSQL](https://www.postgresql.org/) (Version 13)

* **Linux:** Use the official postgres repositories for [Apt](https://wiki.postgresql.org/wiki/Apt) or [Yum](https://yum.postgresql.org/)
* **Mac OS:** Use [HomeBrew](http://brewformulas.org/Postgresql) or [Postgres.app](https://postgresapp.com/)

#### [Redis](https://redis.io/)

* **Linux:** On Ubuntu, you can use [this PPA](https://launchpad.net/%7Echris-lea/+archive/ubuntu/redis-server). Otherwise build from source as detailed in [The Redis quickstart](https://redis.io/topics/quickstart).
* **Mac OS:** Use [HomeBrew](http://brewformulas.org/Redis) or build from source as detailed in [The Redis quickstart](https://redis.io/topics/quickstart).

#### [Ruby](https://www.ruby-lang.org)

Install the [current project ruby version](./.ruby-version), preferrably with
[a Ruby version manager like chruby, rbenv, or rvm](https://www.ruby-toolbox.com/categories/ruby_version_management)

You will also need [Bundler](http://bundler.io/) for installing the project's dependencies.

#### [Node.js](https://nodejs.org) and [Yarn](https://yarnpkg.com)

Yarn is used to manage frontend dependencies for the project. It can be installed by following [the official installation guide](https://yarnpkg.com/lang/en/docs/install/). You will also need to [install Node.js](https://nodejs.org/en/download/package-manager/).

### Running the application

1. Start postgres and redis
1. Install the project's dependencies and prepare the database with `bin/setup`
1. *Optional but recommended*: Import a [production database dump](https://data.ruby-toolbox.com) using `bin/pull_database`
1. In order to access the GitHub GraphQL API for pulling repo data, you need to [create a OAuth token as per GitHub's documentation](https://developer.github.com/v4/guides/forming-calls/#authenticating-with-graphql). No auth scopes are needed. Place the token as `GITHUB_TOKEN=yourtoken` in `.env.local` and `.env.local.test`.
1. Run the services with `foreman start`. You can access the site at `http://localhost:5000`

### Further steps

* You can run the test suite with `bundle exec rspec`
* You can check code style with `bundle exec rubocop`
* During development you can launch [guard](https://github.com/guard/guard) using `bundle exec guard` to continuously check your changes
* The repo has [overcommit](https://github.com/brigade/overcommit) git hooks set up to check your changes before commit, push etc. You can set it up once with `bundle exec overcommit --install`. Whenever the hook config file `.overcommit.yml` changes, you need to verify it's contents and approve the changes with `bundle exec overcommit --sign`
* You can find the [sidekiq](https://github.com/mperham/sidekiq/) web UI at `http://localhost:5000/ops/sidekiq`. Username can be empty, the default password is `development`.

## Production

See our overview of [Configuration](doc/configuration.md) settings for an overview of what needs to be set up to run the app in production.

## Code of Conduct

Everyone participating in this project's development, issue trackers and other channels is expected to follow our [Code of Conduct](./CODE_OF_CONDUCT.md)

## License

This project is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
