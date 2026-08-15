FROM ubuntu:26.04

# The ubuntu base image ships a default user occupying uid 1000; we want our
# own non-privileged dev user on that uid so workspace file ownership matches
RUN userdel -r ubuntu
RUN groupadd --gid 1000 rubytoolbox
RUN useradd rubytoolbox --create-home --shell /bin/bash --uid 1000 --gid 1000

# Base packages: compilers & headers for native gem extensions (pg, psych...),
# plus the general essentials mise and the dev tooling need
RUN apt-get update \
    && apt-get install -y build-essential ca-certificates curl git gnupg libpq-dev libyaml-dev man procps wget zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Set up pgdg official postgres repository
#
# We use the apt repository for the development headers because setting up the PKG CONFIG paths
# with nix-store is somewhat funky / doesn't work with the containerized non-root install
# You can get away installing with `gem install pg -- --with-pg-lib="$(find /nix/store -name libpq.so | tail -n 1)"`
# but that doesnt seem like a super-robust solution, and nix-shell as advised by https://github.com/NixOS/nixpkgs/issues/64530
# doesn't seem to work with our nix setup...
#
RUN wget -O /etc/apt/trusted.gpg.d/pgdg.asc https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ $(. /etc/os-release && echo $VERSION_CODENAME)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN apt-get update \
    && apt-get install -y postgresql-client \
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
#
# Ruby, node.js and pnpm are NOT installed via nix - they come through mise (see below),
# pinned via the project's .ruby-version / .node-version / .mise.toml files.
RUN /bin/bash -l -c "nix-channel --add https://nixos.org/channels/nixpkgs-unstable && nix-channel --update"
RUN /bin/bash -l -c "nix-env -iA \
    nixpkgs.zellij \
    nixpkgs.redis \
    nixpkgs.watchexec \
    nixpkgs.starship \
    nixpkgs.fzf \
    nixpkgs.tig \
    nixpkgs.blesh \
    nixpkgs.atuin"

USER 1000:1000

# Install mise, which manages the project's tool versions (ruby, node, pnpm)
# and serves as its task runner - see .mise.toml at the repository root
RUN curl https://mise.run | sh
ENV PATH="/home/rubytoolbox/.local/share/mise/shims:/home/rubytoolbox/.local/bin:${PATH}"

# We copy the tool version & dependency manifests from the build context and install the
# toolchain and all gems & js packages at this point already - it might not be a perfect
# match, but reduces postCreateCommand runtime when a devcontainer is set up.
COPY --chown=rubytoolbox:rubytoolbox .ruby-version .node-version .mise.toml Gemfile Gemfile.lock package.json pnpm-lock.yaml pnpm-workspace.yaml /tmp/prewarm/
COPY --chown=rubytoolbox:rubytoolbox tasks/ /tmp/prewarm/tasks/
RUN cd /tmp/prewarm && \
    mise trust --quiet && mise install --yes && \
    mise exec -- bundle install && \
    mise exec -- pnpm install --frozen-lockfile

# TODO: Bash completion for git etc.

# Set up some common commands in the bash history, which can then be nicely used together with atuin
COPY --chown=rubytoolbox:rubytoolbox ./.devcontainer/.bash_history /home/rubytoolbox/.bash_history
# Activate mise so the project toolchain is available in interactive shells
RUN echo 'eval "$(~/.local/bin/mise activate bash)"' >> /home/rubytoolbox/.bashrc
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

CMD ["/bin/bash"]
