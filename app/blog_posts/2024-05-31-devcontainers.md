# Easier contributions to Ruby Toolbox via Devcontainers

Hello everyone, I hope you're well!

It's now easier than ever to contribute to the Ruby Toolbox Rails application with a simplified
setup using [devcontainers](https://containers.dev), allowing to easily create a containerized cloud development
environment using [GitHub Codespaces](https://github.com/features/codespaces) or locally using the [devcontainers CLI](https://github.com/devcontainers/cli)
or the [devcontainers VS Code extension](https://code.visualstudio.com/docs/devcontainers/containers).

<p style="text-align: center">
  <img src="/blog/codespaces.png" style="max-width: 75%">
</p>

You can [find the pull request that introduced this on GitHub](https://github.com/rubytoolbox/rubytoolbox/pull/1307) and additional documentation
can be found inside the repository in [.devcontainer/README.md](https://github.com/rubytoolbox/rubytoolbox/blob/main/.devcontainer/README.md).

This functionality goes along with another recent addition - [partial production database dumps](https://github.com/rubytoolbox/rubytoolbox/issues/1205).

In development, it's useful to have a realistic dataset - however, with all the historical data
the complete Ruby Toolbox production dump is quite large and takes a long time to import.

Therefore, [I recently introduced partial production dumps](https://github.com/rubytoolbox/rubytoolbox/issues/1205) which
only provide a meaningful subset (all projects in categories and all categories, plus the top 1000 projects
regardless of having a category, plus only recent gem download data).

Locally, you can simply run `bin/pull_database` to fetch the latest partial dump and import
it into your local database, and you will immediately have a realistic-looking Ruby Toolbox running locally 🎉

This functionality is also utilized for the devcontainers setup on launch, so after launching the
devcontainer.

Best,<br/>Christoph
