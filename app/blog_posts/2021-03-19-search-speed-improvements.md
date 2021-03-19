# Search speed improvements

Hello everyone,

in recent months the response times of the search had become pretty slow, usually taking several seconds to return results.

I therefore spent some time to switch the underlying full text search to utilize [MeiliSearch](https://www.meilisearch.com/) instead of Postgres' built-in full text search as the index after some initial prototyping had shown promising results (Related PRs: [1][PR1] and [2][PR2]).

I did some simple benchmarks after the switch and the response times went down from ~13 seconds to ~1 second. Still not great, but it's back to reasonable usability again. I will keep looking into potential further improvements of this in the next months.

In other news in the beginning of this year I have upgraded the site to run on [Ruby 3][ruby] and the latest version of [Rails][rails] and I'd like to take this opportunity to extend a big thank you to all contributors that continue to make the Ruby ecosystem such a pleasant place.

Stay safe and healthy and until next time!

Best,<br/>Christoph

[PR1]: https://github.com/rubytoolbox/rubytoolbox/pull/831
[PR2]: https://github.com/rubytoolbox/rubytoolbox/pull/845

[ruby]: https://github.com/rubytoolbox/rubytoolbox/pull/801
[rails]: https://github.com/rubytoolbox/rubytoolbox/pull/800
