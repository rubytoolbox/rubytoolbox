# syntax=docker/dockerfile:1
# check=error=true

# Production image for rubytoolbox.com, to be deployed to fly.io (#1748)
#
# The toolchain (ruby, node, pnpm) comes through mise from the same pinned
# version files used for local development and CI: .ruby-version,
# .node-version and .mise.toml - ruby as a precompiled binary.
#
# Build & run locally:
#   docker build -t rubytoolbox .
#   docker run --rm -p 5000:5000 -e SECRET_KEY_BASE=dummy -e DATABASE_URL=... rubytoolbox

FROM ubuntu:26.04 AS base

WORKDIR /rubytoolbox

# Runtime packages: libpq for the pg gem, jemalloc for reduced memory
# fragmentation, libyaml/zlib for the precompiled ruby, postgresql-client
# for database import/maintenance tooling, curl for health checks & debugging
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y ca-certificates curl libjemalloc2 libpq5 libyaml-0-2 postgresql-client tzdata zlib1g && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# mise lives in shared, user-independent locations so the build and runtime
# stages (which run as different users) resolve the same toolchain
ENV MISE_DATA_DIR="/mise" \
    MISE_CONFIG_DIR="/mise" \
    MISE_CACHE_DIR="/mise/cache" \
    MISE_TRUSTED_CONFIG_PATHS="/rubytoolbox/.mise.toml" \
    PATH="/mise/shims:$PATH"

ENV RAILS_ENV="production" \
    RACK_ENV="production" \
    APP_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    LD_PRELOAD="libjemalloc.so.2" \
    MALLOC_CONF="dirty_decay_ms:1000,narenas:2,background_thread:true" \
    RUBY_YJIT_ENABLE="1"

# Throw-away build stage to reduce size of final image
FROM base AS build

# Build packages: compilers & headers for native gem extensions
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libyaml-dev pkg-config zlib1g-dev && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install mise and the pinned toolchain (ruby precompiled, node, pnpm)
RUN curl -fsSL https://mise.run | MISE_INSTALL_PATH=/usr/local/bin/mise sh
COPY .ruby-version .node-version .mise.toml ./
COPY tasks/ tasks/
RUN mise install --yes

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN pnpm install --frozen-lockfile

COPY . .

RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile && \
    rm -rf node_modules

# node and pnpm are only needed for the asset build - drop them (and the
# download caches) so the runtime stage copies a ruby-only toolchain.
# The precompiled ruby ships static libraries, headers, ri docs and an
# unstripped binary - none of which are needed at runtime (~300MB)
RUN mise uninstall node && mise uninstall pnpm && rm -rf /mise/cache && \
    RUBY_DIR="$(mise where ruby)" && \
    rm -rf "$RUBY_DIR"/lib/*.a "$RUBY_DIR"/share/ri "$RUBY_DIR"/include && \
    strip --strip-unneeded "$RUBY_DIR/bin/ruby" && \
    ruby -e "puts RUBY_DESCRIPTION" && bundle exec ruby -e "puts :ok"

# Final stage for app image
FROM base

# node and pnpm were removed after the asset build; stop mise from trying
# to resolve them when its shims run
ENV MISE_DISABLE_TOOLS="node,pnpm"

COPY --from=build /usr/local/bin/mise /usr/local/bin/mise
COPY --from=build /mise /mise
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rubytoolbox /rubytoolbox

# Run and own only the runtime files as a non-root user for security
# (the ubuntu base image ships a default user occupying uid 1000)
RUN userdel -r ubuntu && \
    groupadd --system --gid 1000 rubytoolbox && \
    useradd rubytoolbox --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    mkdir -p /mise/cache && \
    chown -R rubytoolbox:rubytoolbox log tmp /mise/cache
USER 1000:1000

EXPOSE 5000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
