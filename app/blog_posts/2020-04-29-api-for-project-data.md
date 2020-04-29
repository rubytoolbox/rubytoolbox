# API for Project Data

I **[recently][PR] launched [a projects API][docs]** that allows to to **fetch project information from the Ruby Toolbox programmatically**.

**Raw data access has been possible** through the **[production database dumps][exports]** for a [long time][exports-announcement], but this **did not include calculated data like [project health][health-announcement] badges**, and fetching and importing the database dumps also is a bit tedious.

Via the API **you can now fetch this data for arbitrary sets of projects** [easily][api-sample].

A **simple API client is also available as [`rubytoolbox-api`][api-client]**. In the next months I will look into providing additional tooling around this.

* [API documentation][docs]
* [Ruby Client][api-client]
* [Example call][api-sample]

---

On another note you might have noticed that last month **[an issue arose that led projects to lose track of their corresponding](https://github.com/rubytoolbox/rubytoolbox/issues/615) GitHub repo** and report it with a **big red "Repository gone" badge**. This has [been **fixed recently**](https://github.com/rubytoolbox/rubytoolbox/pull/649) and all data **should be displayed correctly again** - sorry for the mixup!

Last but not least as you may know my work on this site is being funded via [Ruby Together](https://rubytogether.org), alongside their [funding of work on critical ruby infrastructure](https://rubytogether.org/team) like RubyGems and Bundler, so if you're not supporting Ruby Together yet but are in a situation you could do so and consider their work worthwile, please consider [becoming a supporter](https://rubytogether.org) ❤️

**Most importantly: Take good care of yourselves, your close ones and your not so close ones too through those strange times, and stay safe and healthy!**

Best,<br/>Christoph

[PR]: https://github.com/rubytoolbox/rubytoolbox/pull/598
[docs]: /pages/docs/api/projects
[api-sample]: /api/projects/compare/rubocop,slim
[exports]: /pages/docs/features/production_database_exports
[exports-announcement]: /blog/2018-09-30/database-exports
[health-announcement]: https://www.ruby-toolbox.com/blog/2018-12-14/project-health-indicators
[api-client]: /projects/rubytoolbox-api
