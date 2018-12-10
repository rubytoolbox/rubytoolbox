# Configuration

**This document explains the various configurable parts of the Ruby Toolbox app that need to be set up for a production deployment**

## PostgreSQL (**required**)

A [PostgreSQL][postgresql] database is required to store data. It's recommended to provide it via the standard `DATABASE_URL` environment variable.

## Redis (**required**)

A [Redis][redis] instance is needed for [sidekiq][sidekiq] background processing. It is recommended to configure it by providing a `REDIS_URL` environment variable.

## Github API Client (**required**)

The `GITHUB_TOKEN` is used by the GraphQL API client to fetch repository data.
Since Github's GraphQL API does not support unauthenticated usage you must provide this, even in local development.

A "Personal Access Token" will do just fine, you can create one by following [Github's instructions](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/). At the time of writing, the direct link to the corresponding settings page is https://github.com/settings/tokens

To keep things nicely separated the main production site has a dedicated [rubytoolbox-bot](https://github.com/rubytoolbox-bot) user account for these tokens.

## Maximum Threads *(optional)*

The `RAILS_MAX_THREADS` option sets the number of threads to be used per [puma web server][puma] and [sidekiq background worker][sidekiq] process. It should be an integer number. A fallback default is pulled from the `.env` file.

## Canonical Domain and SSL enforcement *(optional)*

Setting `CANONICAL_HOST=www.ruby-toolbox.com` will enforce any requests made to the app under a different domain to be redirected to the canonical one.

It will also enable SSL enforcement - if a user visits via plain HTTP, they will be redirected to the SSL variant.

## Appsignal Push API Key *(optional)*

In order to use [AppSignal][appsignal] for exception tracking and performance monitoring, the `APPSIGNAL_PUSH_API_KEY` must be set. It can be created from the appsignal dashboard.

## Sidekiq Admin Dashboard *(optional)*

The [sidekiq web UI](sidekiq-web) is mounted at `/ops/sidekiq`. It is protected by the `SIDEKIQ_PASSWORD` using basic auth. The username is irrelevant.

If this is not configured the app generates a random password on boot.

## Catalog Update Github Webhook *(optional)*

On every update the [catalog][catalog] builds a new JSON export and deploys it to [Github Pages][catalog-gh-pages]. In order to synchronize the live catalog as fast as possible, a Github event webhook can be configured to trigger catalog synchronization on successful catalog builds.

If this is not configured an hourly update cron job will pull the latest data, so this is not a required configuration option.

* Payload URL: `https://www.ruby-toolbox.com/webhooks/github`
* Content-Type: `application/json`
* Secret: `Some Secret String`. Also **set this as `GITHUB_WEBHOOK_SECRET` on the app environment**.
* :heavy_check_mark: Enable SSL Verification
* "Let me select individual events"
  - :heavy_check_mark: Statuses
* :heavy_check_mark: Active

See also https://github.com/rubytoolbox/rubytoolbox/pull/339

## Serve assets from Rails *(optional)*

By setting `RAILS_SERVE_STATIC_FILES` to true the Rails app will be hosting the assets. The regular production app is running on Heroku and has this enabled by default, including asset precompilation that Heroku takes care of automatically.

[appsignal]: https://appsignal.com/
[catalog-gh-pages]: https://rubytoolbox.github.io/catalog
[catalog]: https://github.com/rubytoolbox/catalog
[postgresql]: https://www.postgresql.org/
[puma]: http://ruby-toolbox.com/projects/puma
[redis]: https://redis.io/
[sidekiq-web]: https://github.com/mperham/sidekiq/wiki/Monitoring#web-ui
[sidekiq]: http://ruby-toolbox.com/projects/sidekiq
