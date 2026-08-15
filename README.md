<div align="center">
  <img src="./app/assets/images/logo/regular.svg" width="400px" alt="The Ruby Toolbox"/>

  [![CI](https://github.com/rubytoolbox/rubytoolbox/actions/workflows/ci.yml/badge.svg)](https://github.com/rubytoolbox/rubytoolbox/actions/workflows/ci.yml) [![Depfu](https://badges.depfu.com/badges/84ab24dbd83e15c8dfd36144e10d14f2/overview.svg)](https://depfu.com/github/rubytoolbox/rubytoolbox) [![This project is using Percy.io for visual regression testing.](https://percy.io/static/images/percy-badge.svg)](https://percy.io/rubytoolbox/rubytoolbox)

  **Find actively maintained & popular open source software libraries for the Ruby programming language**
</div>

The Ruby Toolbox is a catalog of all Rubygems that keeps track of popularity and health metrics to help you choose a reliable library.

**This is the source code for the site you can visit at https://www.ruby-toolbox.com/**

## Development

**💡 We provide a ready devcontainer configuration which you can use locally or on GitHub codespaces - for further details please refer
to [.devcontainer/README.md](./.devcontainer/README.md). This is the easiest way to get a fully functional development setup.**

### Prerequisites

You will need [PostgreSQL](https://www.postgresql.org/) as the database and [Redis](https://redis.io/) for background job processing — see [Configuration](./doc/configuration.md) for details and installation pointers.

#### Tooling via [mise](https://mise.jdx.dev)

Tool versions ([Ruby](./.ruby-version), [Node.js](./.node-version) and [pnpm](./.mise.toml)) are managed with
[mise](https://mise.jdx.dev), which also serves as the project's task runner. After
[installing mise](https://mise.jdx.dev/getting-started.html), run `mise install` inside your checkout
to get the full toolchain.

### Running the application

1. Start postgres and redis
1. Install the project's dependencies and prepare the database with `mise run setup`
1. *Optional but recommended*: Import a partial production database dump using [`bin/pull_database`](./bin/pull_database). You can also load some test data quickly by running `rake db:fixtures:load`
1. In order to access the GitHub GraphQL API for pulling repo data, you need to provide a `GITHUB_TOKEN` — see the [Github API Client configuration](./doc/configuration.md#github-api-client-required).
1. Run the development processes (web, worker & vite) with `mise run server`. You can access the site at `http://localhost:5000`

### Further steps

* You can run the test suite with `mise run test`
* You can check code style and security with `mise run lint` (and auto-format with `mise run format`)
* During development you can launch [guard](https://github.com/guard/guard) using `bundle exec guard` to continuously check your changes
* The repo has [overcommit](https://github.com/brigade/overcommit) git hooks set up to check your changes before commit, push etc. You can set it up once with `bundle exec overcommit --install`. Whenever the hook config file `.overcommit.yml` changes, you need to verify it's contents and approve the changes with `bundle exec overcommit --sign`
* You can find the [sidekiq](https://github.com/mperham/sidekiq/) web UI at `http://localhost:5000/ops/sidekiq`. Username can be empty, the default password is `development`.

## Production

See our overview of [Configuration](doc/configuration.md) settings for an overview of what needs to be set up to run the app in production, and [Deployment](doc/deployment.md) for how the production app on fly.io is deployed and operated.

## Code of Conduct

Everyone participating in this project's development, issue trackers and other channels is expected to follow our [Code of Conduct](./CODE_OF_CONDUCT.md)

## License

This project is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
