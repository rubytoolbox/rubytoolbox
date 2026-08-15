# frozen_string_literal: true

# RELEASE_VERSION identifies the currently deployed release and is used for
# busting fragment caches on deployments (see ApplicationHelper#expiring_cache).
# On fly.io it defaults to the deployed image reference; other platforms (or
# a manual override) can set RELEASE_VERSION directly.
ENV["RELEASE_VERSION"] ||= ENV["FLY_IMAGE_REF"] if ENV["FLY_IMAGE_REF"]
