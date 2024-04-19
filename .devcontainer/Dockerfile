FROM ruby:3.3.0

# Create non-privileged dev user
RUN addgroup --gid 1000 rubytoolbox
RUN adduser rubytoolbox --gecos "" --disabled-password --uid 1000 --gid 1000

# Set up pgdg official postgres repository
#
# We use the apt repository for the development headers because setting up the PKG CONFIG paths
# with nix-store is somewhat funky / doesn't work with the containerized non-root install
# You can get away installing with `gem install pg -- --with-pg-lib="$(find /nix/store -name libpq.so | tail -n 1)"`
# but that doesnt seem like a super-robust solution, and nix-shell as advised by https://github.com/NixOS/nixpkgs/issues/64530
# doesn't seem to work with our nix setup...
#
RUN wget -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN apt-get update \
    && apt-get install -y postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Install chrome for browser-based capybara specs
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/chrome.list
RUN apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Set up nix, which we will use for installing utilities, and switch to dev user
# We use the determinate systems nix installer as per
# https://github.com/DeterminateSystems/nix-installer#in-a-container
RUN curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux \
    --extra-conf "sandbox = false" \
    --init none \
    --no-confirm

# Set up nix unstable as the source channel, install tooling
# Note that we currently don't add sudo access to the dev user and the nix container install doesn't support
# non-root installs, so adding new tools can only be done as root when building this image
#
# We use nix here because it provides an easy way to install some useful tools in reasonably recent versions
# without having to build & maintain the corresponding canonical install process for each, i.e. using
# offical APT repos or fetching from github releases.
RUN /bin/bash -l -c "nix-channel --add https://nixos.org/channels/nixpkgs-unstable && nix-channel --update"
RUN /bin/bash -l -c "nix-env -iA \
    nixpkgs.man \
    nixpkgs.zellij \
    nixpkgs.nodejs_20 \
    nixpkgs.yarn \
    nixpkgs.redis \
    nixpkgs.watchexec \
    nixpkgs.starship \
    nixpkgs.fzf \
    nixpkgs.tig \
    nixpkgs.atuin"

USER 1000:1000

# Install latest rubygems & bundler
RUN gem update --system && gem install bundler

# RADAR: We could consider fetching the Gemfile & Gemfile.lock from main branch on github and bundling
# at this point already - it might not be a perfect match, but would likely highly increase postCreate runtime
# However, this only makes sense alongside a cached base build that can be used for codespaces, which
# needs to be figured out as well.

# TODO: Bash completion for git etc.

# Set up some common commands in the bash history, which can then be nicely used together with atuin
COPY --chown=rubytoolbox:rubytoolbox ./.devcontainer/.bash_history /home/rubytoolbox/.bash_history
# Starship provides a nicer terminal prompt with contextual information about git branch, ruby version etc.
RUN echo 'eval "$(starship init bash)"' >> /home/rubytoolbox/.bashrc
# Atuin provides a highly improvied shell history (CTRL+R)
RUN echo 'eval "$(atuin init bash)"' >> /home/rubytoolbox/.bashrc

# Default value to allow debug server to serve content over GitHub Codespace's port forwarding service
# The value is a comma-separated list of allowed domains
ENV RAILS_DEVELOPMENT_HOSTS=".githubpreview.dev,.preview.app.github.dev,.app.github.dev"

# Configure TCP access for postgres database
ENV DATABASE_HOST="localhost"
ENV DATABASE_PORT="5432"
ENV DATABASE_USERNAME="rubytoolbox"
ENV DATABASE_PASSWORD="rubytoolbox"

# Ruby base image defaults to irb when no command given, but we want bash
CMD ["/bin/bash"]
