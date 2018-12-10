# Configuration

**This document explains the various configurable parts of the Ruby Toolbox app that need to be set up for a production deployment**

`REDIS_URL`
`DATABASE_URL`
`RAILS_SERVE_STATIC_FILES`
`RAILS_MAX_THREADS`

## Github API Client

* `GITHUB_TOKEN`

## Canonical Domain and SSL enforcement (*optional*)

Setting `CANONICAL_HOST=www.ruby-toolbox.com` will enforce any requests made to the app under a different domain to be redirected to the canonical one.

It will also enable SSL enforcement - if a user visits via plain HTTP, they will be redirected to the SSL variant.


## Appsignal Push API Key (*optional*)

In order to use [AppSignal][appsignal] for exception tracking and performance monitoring, the `APPSIGNAL_PUSH_API_KEY` must be set. It can be created from the appsignal dashboard.

## Sidekiq Admin Dashboard (*optional*)

The [sidekiq web UI](sidekiq-web) is mounted at `/ops/sidekiq`. It is protected by the `SIDEKIQ_PASSWORD` using basic auth. The username is irrelevant.

If this is not configured the app generates a random password on boot.

## Catalog Update Github Webhook (*optional*)

On every update the [catalog][catalog] builds a new JSON export and deploys it to [Github Pages][catalog-gh-pages]. In order to synchronize the live catalog as fast as possible, a Github event webhook can be configured to trigger catalog synchronization on successful catalog builds.

If this is not configured an hourly update cron job will pull the latest data, so this is not a required configuration option.

* Payload URL: `https://www.ruby-toolbox.com/webhooks/github`
* Content-Type: `application/json`
* Secret: `Some Secret String`. Also **set this as `GITHUB_WEBHOOK_SECRET` on the app environment**.
* :check: Enable SSL Verification
* "Let me select individual events"
  - :check: Statuses
* :check: Active

See also https://github.com/rubytoolbox/rubytoolbox/pull/339


[appsignal]: https://appsignal.com/
[catalog]: https://github.com/rubytoolbox/catalog
[catalog-gh-pages]: https://rubytoolbox.github.io/catalog
[sidekiq-web]: https://github.com/mperham/sidekiq/wiki/Monitoring#web-ui
