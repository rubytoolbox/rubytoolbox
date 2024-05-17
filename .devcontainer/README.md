# Ruby Toolbox Devcontainer

**Welcome to the Ruby Toolbox devcontainer README!**

The devcontainer allows you to easily set up a development environment for
the Ruby Toolbox Ruby on Rails application locally or in the cloud.

## References

* https://containers.dev
* https://github.com/devcontainers/cli
* https://code.visualstudio.com/docs/devcontainers/containers
* https://docs.github.com/en/codespaces/overview

## Local requirements

To run things locally, you will need docker and docker-compose installed.

At the end of the setup, you will have a fully prepared development environment,
with redis & postgres running, the database prepared, a realistic data subset loaded,
and helpful tooling for the command line pre-configured.

## Setting things up

### Using GitHub Codespaces

* Open [the project repository on GitHub](https://github.com/rubytoolbox/rubytoolbox)
* Click the `<> Code` button and switch to the Codespaces panel
* Create a codespace

### Using VS Code

Obviously, you will need Visual Studio Code installed for this :)

* `git clone git@github.com:rubytoolbox/rubytoolbox.git` and open it in VS Code.
* Install the [official VS Code dev containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
* Open the command palette with `CTRL+SHIFT+P` and run "Dev Containers: Rebuild and reopen in dev container"
* This will build and launch the dev containers, including a bash terminal

### Using devcontainers CLI

You will need nodejs installed locally to use the CLI.

* `git clone git@github.com:rubytoolbox/rubytoolbox.git` and open it in a terminal
* Install the CLI with `npm install -g @devcontainers/cli`
* Build the devcontainer docker images with `devcontainer --workspace-folder . build`
* Launch the devcontainer docker images with `devcontainer --workspace-folder . up`
* Open a bash shell in the running devcontainer with `devcontainer exec --workspace-folder . /usr/bin/env bash`

At the time of writing, the devcontainer CLI doesn't have functionality to teardown and cleanup yet,
so here's a command you can run to SIGKILL and remove all devcontainers:

> **⚠ Beware that this will remove any devcontainers, not just those for the Ruby Toolbox project! ⚠**

```bash
docker ps -a | grep devcont | cut --fields 1 -d " " | xargs docker rm -f
```
