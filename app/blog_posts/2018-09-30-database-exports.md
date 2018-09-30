# Production database exports

If you visit [data.ruby-toolbox.com](https://data.ruby-toolbox.com) you can
now download recent Ruby Toolbox production postgres database dumps.

The Ruby Toolbox dataset is interesting in that it combines a whole bunch of
data about Ruby open source libraries from the Rubygems and Github APIs in one
single place.

There's two reasons I decided to set this up:

### Enable research into the state of the Ruby open source ecosystem

I hope making this data more easily available to everyone instead of having to
query and link all of it by yourself from the respective public APIs will
enable some interesting research into the state of the Ruby ecosystem

In the coming months I would like to put more emphasis on making it visible at
a glance how healthy a project is, based on for example recent commit
activity or the number of reverse dependencies of libraries.

If you look into the dataset and find some interesting aspects that should be displayed on the Ruby Toolbox, please [open an issue for further discussion on
Github](https://github.com/rubytoolbox/rubytoolbox)!

### Lower the barrier for contributing to Ruby Toolbox itself

If you `git clone` the [Ruby Toolbox](https://github.com/rubytoolbox/rubytoolbox) repo, you can now import the most recent dump into your local
development db with a simple `bin/pull_database`.

The current Ruby Toolbox app relies a lot on having a reasonable local dataset for development, and I hope making local setup as frictionless as possible will help you to contribute to the Ruby Toolbox itself.

Best,

Christoph
