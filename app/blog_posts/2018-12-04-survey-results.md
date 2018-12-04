# Community Survey Results

Thanks to [Ruby Together](https://www.rubytogether.org) I'll be [working on Ruby Toolbox as my main project in December and January](/blog/2018-11-05/community-survey). To help me find out what areas of the Ruby Toolbox to prioritize [I ran a community survey](/blog/2018-11-05/community-survey) to find out what community members wanted to see improved.

The survey took place from November 5th until December 2nd 2018 and a surprisingly exact 100 people took part. I assure you no foul play was involved in getting to this number. :)

The survey mostly consisted of a few intentionally fairly open questions; my goal was to get an honest feedback from the community and to enable me to focus my time in the next weeks on what matters most to you. You all did an absolutely wonderful job at that, and I've received a tremendous amount of insights. Thank you very much! In general I think we have great alignment between what you consider most helpful to you and the direction I want to take, so that's nice :)

I'd also like to give a big thanks to Stephanie Morillo for providing great advice and support around the survey!

In this post, I’ll share the survey results.

I have decided to mostly group the replies around features, both existing that should be improved as well as new ones. To give your voices room and enable transparency I have added your suggestions as quotes, so this is going to be a rather long read, sorry about that! Below you can find a brief overview if you're in a hurry.

In the coming weeks I will work on bringing your suggestions to life, so if you want to follow along with that please keep an eye on [rubytoolbox/rubytoolbox](https://github.com/rubytoolbox/rubytoolbox) on GitHub. I have also set up a [community chatroom on gitter](https://gitter.im/rubytoolbox/Lobby) where I should be reachable during work days if you have any questions or would like to join the discussion.

**tl;dr Here's a brief overview of the main outcomes:**

* Users generally seem happy with the site, yay :)
* However, the site could do a better job at marketing and explaining its purpose to newcomers
* Discovery of trending projects and clear recognizability of deprecated ones were the two highest-voted features
* Categories should be cleaned up and improved. There should be better explanations on how to contribute to the catalog as well
* Search should be improved
* Many users would like to be able to sort by other things than the score
* A way to compare projects side by side was also requested often and was popular in the feature vote
* The UI is a bit too reduced

And without further ado, on to the detailed results:

---

### What is your experience with Ruby?

<table>
  <tr>
    <th>Expert</th>
    <td>59</td>
  </tr>
  <tr>
    <th>Intermediate</th>
    <td>36</td>
  </tr>
  <tr>
    <th>Beginner</th>
    <td>3</td>
  </tr>
  <tr>
    <th><em>(no answer)</em></th>
    <td>2</td>
  </tr>
</table>

Somewhat to my surprise, by far the largest group of respondents consider themselves expert Ruby users, with only very few "beginner" users. This is quite contrary to my expectation and to what other people also wrote, in that the site can be helpful especially to beginners. There were also quite a few suggestions to generally do a better job at marketing the site.

<!-- -->
> As odd as this sounds, a bit of marketing perhaps. Rubygems is the defacto place to go as you must to get gems, I wonder how people who don't know about ruby toolbox start here. I wonder how when people are blogging about gems, what features would make them link into this site over others.
<em><small>(What can the Ruby Toolbox do better?)</small></em>

<!-- -->
> Marketing of the project
<em><small>(What can the Ruby Toolbox do better?)</small></em>

<!-- -->
> Add a blog section, so the site might become more popular
<em><small>(Other)</small></em>

<!-- -->
> I thought it was down, so I don't know. I used to use it to compare between gems and find out about new alternatives.
<em><small>(What does the Ruby Toolbox do well?)</small></em>

<!-- -->
> When I'm exploring something unfamiliar, Ruby toolbox assumes the user has some knowledge of tool terminology. For instance, if I was exploring databases for the first time, I might not know that an "Object-relational mapping" tool is.
<em><small>(What can the Ruby Toolbox do better?)</small></em>

<!-- -->
> No clue what it is, or how its supposed to help me.
<em><small>(What does the Ruby Toolbox do well?)</small></em>

In general, I'm very aware the Ruby Toolbox could do a much better job of onboarding new users. There's more on this topic below on the start page and guides sections, but as it stands there is very little for an unfamiliar visitor to understand how the site can be helpful to them. To that end, I'm planning on improving the landing page and some of the guides to help clarify what the Toolbox is and how it helps Rubyists.

This could be a wild guess, but I suspect some beginners might have felt they didn't have much to contribute in filling out the survey. If we do another survey in the future, I will add specific callouts to encourage more participation form early-career Rubyists.

Additionally, I would like to reach out to providers of entry-level resources with the goal of seeing if they could introduce their learners to the Toolbox. If you are providing learning resources in the Ruby community and have some ideas around that, please reach out via one of the contact methods listed in the footer :)

Finally, if you have already been working with Ruby for a while chances are you are working with juniors - if you think this site would be helpful to them, please spread the word :)

### How often do you visit the Ruby Toolbox?

<table>
  <tr>
    <th>What is a Ruby Toolbox?</th>
    <td>2</td>
  </tr>
  <tr>
    <th>A few times per year</th>
    <td>31</td>
  </tr>
  <tr>
    <th>Monthly</th>
    <td>44</td>
  </tr>
  <tr>
    <th>Weekly</th>
    <td>20</td>
  </tr>
  <tr>
    <th>Daily</th>
    <td>1</td>
  </tr>
  <tr>
    <th><em>(no answer)</em></th>
    <td>2</td>
  </tr>
</table>

The majority of users visit on a regular basis, which matches my expectation for a tool that you reach for whenever you need it's help.

### What does the Ruby Toolbox do well?

*Disclaimer: This is the only section where I have omitted a whole bunch of survey replies since they were very similar. I tried my best to reflect the general tone in the picked quotes.*

<!-- -->
> Categorized list of gems based on need/use. Easy to go straight to what you probably want to use in your project.
<em><small>(What does the Ruby Toolbox do well?)</small></em>

<!-- -->
> Providing all the info I need.
<em><small>(What does the Ruby Toolbox do well?)</small></em>

<!-- -->
> Categorize gems and give a rough and relatively simple overview over its health and popularity.
<em><small>(What does the Ruby Toolbox do well?)</small></em>

<!-- -->
> Categorisation of packages in a way that makes a group easily searchable by intention.
> Best source of knowledge of relative popularity and if a repository is stale/maintained.
<em><small>(What does the Ruby Toolbox do well?)</small></em>

<!-- -->
> Provides a high level survey and health check of libraries in a category.
<em><small>(What does the Ruby Toolbox do well?)</small></em>

<!-- -->
> Show project metrics which make it easy to spot if the project being actively maintained.
<em><small>(What does the Ruby Toolbox do well?)</small></em>

<!-- -->
> It helps me discover new repositories instead of using the mainstays.
<em><small>(What does the Ruby Toolbox do well?)</small></em>

<!-- -->
> The classic site was my go to for a semi-curated list of handy purpose built gems.
<em><small>(What does the Ruby Toolbox do well?)</small></em>

<!-- -->
> I had no reason to search for another curated list so far.
<em><small>(What does the Ruby Toolbox do well?)</small></em>

<!-- -->
> Keeps me up to date on community gems for specific purposes
<em><small>(What does the Ruby Toolbox do well?)</small></em>

<!-- -->
> Great as a reference for gems in a particular category. Typically use to find good candidates. Sometimes browse more generally for ideas.
<em><small>(What does the Ruby Toolbox do well?)</small></em>

<!-- -->
> Shows me alternatives. Allows me to vet new dependencies and make sure they are well maintained and supported by the community.
<em><small>(What does the Ruby Toolbox do well?)</small></em>

<!-- -->
> Provide a great overview of available gems, their alternatives, their development state, their usage, ...
<em><small>(What does the Ruby Toolbox do well?)</small></em>

<!-- -->
> It's a good catalog
<em><small>(What does the Ruby Toolbox do well?)</small></em>

<!-- -->
> Quickly find a gem in a category of functionality I need. Then lets me pick which one(s) are still alive. I have found it to be missing entries sometimes, but you can add them on GitHub which is easy enough for a dev.
<em><small>(What does the Ruby Toolbox do well?)</small></em>

<!-- -->
> Curated collections
<em><small>(What does the Ruby Toolbox do well?)</small></em>

<!-- -->
> When I want to explore new ways to do familiar stuff, Ruby Toolbox does an awesome job showing all of the options, regardless of how popular.
<em><small>(What does the Ruby Toolbox do well?)</small></em>

So generally it seems the site serves its purpose well for most users.

One thing I sometimes notice in conversations is that users are not aware of the fact that the Toolbox is not only limited to the categories, it also lists all RubyGems (and has since 2011) and can help you check the health and popularity of all of them. Again, if this is happening to users regularly the site should communicate this aspect more clearly:

<!-- -->
> Needs to be more complete in gems - should be able to get all gems from rubygems and have an entry for it.
<em><small>(What can the Ruby Toolbox do better?)</small></em>

### Features

As previously stated, the main purpose of this survey was to figure out what improvements are the most relevant to the community so I can emphasize those in my work on the site. There was a multi-response vote on a few features I proposed, as well as an open text box for other suggestions.

##### What features would you like to see added or improved?

<table>
  <tr>
    <th>Detection and flagging of unmaintained projects</th>
    <td>73</td>
  </tr>
  <tr>
    <th>Discovery of new & trending projects</th>
    <td>72</td>
  </tr>
  <tr>
    <th>Project comparisons (select a few projects and compare data side-by-side)</th>
    <td>48</td>
  </tr>
  <tr>
    <th>Search</th>
    <td>32</td>
  </tr>
  <tr>
    <th>Guides (i.e. tips for picking a library)</th>
    <td>29</td>
  </tr>
  <tr>
    <th>Project changelogs</th>
    <td>17</td>
  </tr>
  <tr>
    <th>Project READMEs</th>
    <td>15</td>
  </tr>
  <tr>
    <th>Historical Data</th>
    <td>14</td>
  </tr>
  <tr>
    <th>API</th>
    <td>11</td>
  </tr>
  <tr>
    <th>Command line interface</th>
    <td>5</td>
  </tr>
  <tr>
    <th>More metrics</th>
    <td>4</td>
  </tr>
</table>

##### Categories

<!-- -->
> Categorization
<em><small>(Feature Requests)</small></em>

<!-- -->
> Collections that relate together (even if not under same category. One example is the dry-rb gems.
<em><small>(Feature Requests)</small></em>

<!-- -->
> Better categorization. I think to start with simply move all the Rails categories under Rails - it's polluting the homepage.
> Gems can be discovered through different category paths like Sidekiq can be from background processing and from Rails - background processing (as an example).
<em><small>(Feature Requests)</small></em>

<!-- -->
> Maybe implement some sort of tagging feature?
<em><small>(What can the Ruby Toolbox do better?)</small></em>

<!-- -->
> tags, apart from categories, and less concrete
<em><small>(What can the Ruby Toolbox do better?)</small></em>

<!-- -->
> Better categorization and search.
<em><small>(What can the Ruby Toolbox do better?)</small></em>

<!-- -->
> I often think the categories could be done better, but I really don't have any specific ideas about how to go about that.
<em><small>(What can the Ruby Toolbox do better?)</small></em>

<!-- -->
> In addition to improving search, I suggest putting additional work into categorization. Is there a way to improve how tools are categorized, and how to find tools for which an appropriate category does not yet exist?
<em><small>(What can the Ruby Toolbox do better?)</small></em>

<!-- -->
> the suggestion
<em><small>(What can the Ruby Toolbox do better?)</small></em>

<!-- -->
> Honestly the site is just about perfect. All it really needs is a bit more editorial time spent on each category. And also in adding/editing the categories themselves.
<em><small>(What can the Ruby Toolbox do better?)</small></em>

As you can see, the topic of categories came up a lot. I don't think adding more layers of categories into the hierarchy would really help, because it could  make things harder to discover. There is, however, definitely a need for a spring cleaning and some restructuring of the existing categories. I will look into this in the next few weeks.

It would probably also be helpful to flag some categories as "essential" and emphasize them on the site somehow (see the section below). This might also make it easier to understand the purpose of the site for newcomers.

A while ago GitHub also added repository tags. I want to look into adding those as a second way of categorization. As things usually go with tags on the internet I do have the suspicion that no two actually comparable projects use the same set of tags on their repositories though, so let's see how that goes :) An extra challenge here will likely be the UX part of it, to avoid confusion about what these category and tag things are, where they are coming from and how they differ.

<!-- -->
> (...) Also more project categorization coverage with ability to multi-categorize.
<em><small>(What can the Ruby Toolbox do better?)</small></em>

Multi-categorizations have been possible since the relaunch of the site, please send PRs against the [catalog](https://github.com/rubytoolbox/catalog) if something is wrong :) I will try to find ways of documenting those features better.

<!-- -->
> Better tagging or categorization of gems. For example, if I'm looking at the acts as paranoid gem, it'd be nice to have a link to a "soft-delete" category that suggests alternatives like paranoia and discard.
<em><small>(Feature Requests)</small></em>

From individual projects, the category it is filed under is already linked. However, on the old site there was a sidebar which also featured "similar categories", and "similar projects" sections which linked directly to related projects. Those have not re-appeared yet mostly due to a lack of time, but it would indeed make sense to bring them back.

##### Contributing to the catalog

<!-- -->
> Maybe make it easier to add a project. (I don't recall ever having seen a way to get a project added.)
<em><small>(What can the Ruby Toolbox do better?)</small></em>

To give some background: On the old Toolbox site project changes could be submitted directly on the site and went to a review page. Building and maintaining such a feature costs time, so for the new site I decided to keep it simple and just go with GitHub pull requests. However, I think all ceremony around sending a PR for minor changes still has a lot of friction, and the process surely can still be improved. On the other hand having a transparent and documented process is great. I think the docs can be improved here as well.

<!-- -->
> Faster add alternative libraries. Some PRs are very long unreviewed and not responded to.
<em><small>(What can the Ruby Toolbox do better?)</small></em>

Currently, it sometimes takes around a month to get a valid PR merged, as I usually do them in one fell swoop. I will do my best to improve this situation. If you are interested in helping to [maintain the catalog](https://github.com/rubytoolbox/catalog), please let me know!

##### Search & Sorting

<!-- -->
> Need better sorting and filtering/facets
<em><small>(Feature Requests)</small></em>

<!-- -->
> SORTING (by popularity, last commit time etc.)
<em><small>(Feature Requests)</small></em>

<!-- -->
> did I already say SORTING
<em><small>(What can the Ruby Toolbox do better?)</small></em>

<!-- -->
> Search. Quick example: if I search by "swagger" it won't find "rswag" gem which is a pretty popular project. I missed it when I was looking for a tool like that. Found it thanks to some blog post.
<em><small>(What can the Ruby Toolbox do better?)</small></em>

<!-- -->
> Better sorting and filters of projects --  I'd like to sort by recent activity (ie. projects that are still active, updated within past 6 months) and to filter out old projects (ie. last activity date older than 6/9/12/18+ months). Some categories have several dozen projects listed and finding the useful gem that is still active with sufficient followers/likes/forks sometimes gets buried deep down the list surrounded by others not touched in 5+ years. Can easily overlook a real gem of a Gem due to the noise.
<em><small>(What can the Ruby Toolbox do better?)</small></em>

<!-- -->
> Searching for keywords or patterns or concepts sometimes fails to yield any results. Manually tracking down the category will list gems that do the thing I searched for. So it seems that indexing isn't including all needed and wanted terms and keywords.
<em><small>(What can the Ruby Toolbox do better?)</small></em>

<!-- -->
> Sometimes I search for a gem by name and I would like to find similar (better) gems. This is sometimes very tricky. (e.g. gem is not suited in the proper category)
<em><small>(What can the Ruby Toolbox do better?)</small></em>

<!-- -->
> put more highlight on "last release" metric of a gem. and let me sort gems by that metric.
<em><small>(What can the Ruby Toolbox do better?)</small></em>

<!-- -->
> search engine
<em><small>(What can the Ruby Toolbox do better?)</small></em>

<!-- -->
> Take a look at https://www.algolia.com as a search solution, it's free for opensource
<em><small>(Other)</small></em>

Regarding improvements of the search feature, I already created a [corresponding issue](https://github.com/rubytoolbox/rubytoolbox/issues/109) on GitHub when the new site's first version of search went live earlier this year. There is a lot of room for improvement both in result quality and presentation.

Additionally, a lot of participants requested custom sorting for category and search result views. That would surely make a lot of sense.

I will work on both of these topics in the next weeks.

##### Start page

<!-- -->
> The entrance to categories is a bit cluttered (the categories overview lists all subcategories, too which is good for CTRL+F but making a high-level overview more difficult).
<em><small>(What can the Ruby Toolbox do better?)</small></em>

<!-- -->
> Homepage
<em><small>(What can the Ruby Toolbox do better?)</small></em>

To be fully honest, I think the current start page of the site is a barren wasteland. It does serve its purpose of showing the categories, but lacks so many other aspects. I mentioned much of this in the section regarding Ruby experience, but this page should become much more welcoming, giving users an explanation of what they can expect from the site and how they can use it to their benefit. My current plan here is to make a fairly slim landing page similar to [Rubygems.org](https://www.rubygems.org) which can point to further, more focused pages like the categories overview. I will work on this soon.

##### UI & Design

<!-- -->
> The design could be a little spruced up. I like the information density, but I think it could use a little more flair. However, I definitely prefer this design to the old one so don't go back to that :D
<em><small>(Feature Requests)</small></em>

<!-- -->
> Design. The new web design looks more modern but somehow also makes it harder to distinguish between different parts of a page. More color/contrast or other visual aids would be appreciated.
<em><small>(Feature Requests)</small></em>

<!-- -->
> I like the new minimal UI and collection of metrics. It can still use another iteration to build a visual information hierarchy.
<em><small>(What does the Ruby Toolbox do well?)</small></em>

<!-- -->
> Do better website design, its sells
<em><small>(What can the Ruby Toolbox do better?)</small></em>

<!-- -->
> The UI and collection of metrics can still use another iteration to build a visual information hierarchy. Why? Each gem card has a lot of data to digest and the gem name is not visually strong like a H1 or H2 header to anchor the reader. A UI designer skilled in information hierarchy can best help with this, basically each gem card should have an H1, H2, body, muted body like hierarchy visually. You kind of have it but it needs more tuning to be super readable.
<em><small>(What can the Ruby Toolbox do better?)</small></em>

<!-- -->
> Not sure; I tend to like the simple look, but it's difficult to navigate all the categories. Also a bit too much project detail in the category, which makes me have to scroll a lot. Mostly layout. <em><small>(What can the Ruby Toolbox do better?)</small></em>

<!-- -->
> A percentage of issues closed in the short summary of projects does not give much indication. Displaying the open issues count metric instead would be awesome.
<em><small>(What can the Ruby Toolbox do better?)</small></em>

<!-- -->
> dark mode!
<em><small>(Feature Requests)</small></em>

<!-- -->
> (...) Also, the UI design is excellent.
<em><small>(What does the Ruby Toolbox do well?)</small></em>

<!-- -->
> Its former website. Current website UI is not useful to me. Thanks for working on this anyways.
<em><small>(What does the Ruby Toolbox do well? / Other)</small></em>

Lots of excellent points were made here. I know that the design is somewhat too minimalistic, and sometimes makes it hard to identify the most important aspects. White space usage probably is also too liberal, and it could make better use of larger screens. I will iterate on this.

##### Trending projects

This was the second-highest topic on the feature vote.

<!-- -->
> it would be good to have at the main page something like apps of the month or hot tools. this is what i miss in the place.
<em><small>(Feature Requests)</small></em>

<!-- -->
> More focus on newcomers / current usage (but at the same time respect "stable" libraries that do not change that often but do their job as expected)
<em><small>(What can the Ruby Toolbox do better?)</small></em>

<!-- -->
> highlight libraries that are becoming popular
<em><small>(What can the Ruby Toolbox do better?)</small></em>

<!-- -->
> Most downloaded projects aggregating all categories: it would be useful to start a new project with most used tools.
<em><small>(Feature Requests)</small></em>

<!-- -->
> I dont know, maybe an competition? With prizes? Like, the best gem of the year?
<em><small>(What can the Ruby Toolbox do better?)</small></em>

For a while now I wanted to set up dedicated pages for each metric featuring explanations on why it can be interesting as well as graphs on how the values distribute across the entire RubyGems base. This could also feature the highest-ranking projects, both of all time and, where applicable, within the last year.

Some particularly interesting of those might also make sense to be showcased on the improved start page, for example a list of the most-downloaded gems first released in the last 12 months.

To enable general trends analysis, the Toolbox must start keeping track of historical data again. The old site used to do this for some metrics, but after the rebuild only the current state is kept in the database. Via [database backups](https://data.ruby-toolbox.com/) at least the history of the last few months could be manually reproduced to backfill data if this gets built, maybe for some metrics other sources exist to get historical data as well.

##### Deprecation

This topic was the highest-voted in the feature vote, and it's also seen quite a bit of discussion [on github](https://github.com/rubytoolbox/rubytoolbox/issues/7) for quite some time already.

<!-- -->
> I'm OK with showing older projects, maybe just flag/cordone. Because sometimes you are trying to build something and there is not much out there, so you want to find something even a scrap of old code you can build upon.
<em><small>(Feature Requests)</small></em>

This user summed up my stance on this very well. I think even some old, outdated code can sometimes lead to great insights and inspiration, so I don't think hiding projects from the site would be a great idea.

If you "know how to read the numbers" you can get this information on the Toolbox already, but I think it would be great to have some visual cues to aid in this. I will likely start with some hard-coded warnings (i.e. no release in 3 years) and hopefully we can iterate our way to a dependable and transparent solution here.

<!-- -->
> Audit tool as a Command line interface to detect if a used gem has been maintained or has strong communities. And on the metrics side, watchers, forks and GitHub stars
<em><small>(Feature Requests)</small></em>

That's a great idea for a paid product right there ;)

An automated tool could be of great help to spot risks in your codebase. Assuming the deprecation detection or ranking I wrote about is solid, at some point in the future it should be fairly straight forward to wrap it in an API and consume it from a CLI client. I'm not putting this on my schedule right now but I think it would be a very useful thing to have.

For the time being, you could give the [how_is](https://github.com/how-is/how_is) a try in this regard.

##### Comparisons

> Project comparisons are mentioned, I would think without a ton of manual effort, it may result in gems trying to one-up each other or the comparison being superficial. Unless you have a specifically good idea on how I'd hate for your valuable time to be tied up to it.
<em><small>(Feature Requests)</small></em>

<!-- -->
> More categories, or comparison of arbitrary gems
<em><small>(Feature Requests)</small></em>

<!-- -->
> side-by-side comparisons of key gem attributes such as libhunt.com does (https://ruby.libhunt.com/compare-paper_trail-vs-audited?rel=cmp-lib) -- but do it better, allow more than just 2 side-by-side comparisons
<em><small>(Feature Requests)</small></em>

This came in third in the feature vote. I think it would be very helpful in many situations to compare the metrics of projects side-by-side, I will work on this.

##### Community features

<!-- -->
> Personal notes and ratings which are non-public
<em><small>(Feature Requests)</small></em>

<!-- -->
> * Reviews
> * Experiences from other developers with the library
<em><small>(Feature Requests)</small></em>

Back when version 2 of the site launched in 2011 I also added a whole slew of community-oriented features: Logging in, starring projects, project commenting, blog post link aggregation and more. Ultimately, those features never caught up enough participation to become really useful.

I think the additional burdens of building and maintaining social features in a web app in general, as well as moderating a community and taking care of all the data privacy problems that storing this slew of personally identifiable information brings is not worth it for the Ruby Toolbox at the moment.

##### Charts

<!-- -->
> For each category, I want a bar chart of the top X projects. Just like the old website.
> This would allow me to know at a glance what the most famous libs are and how famous they are.
<em><small>(Feature Requests)</small></em>

<!-- -->
> visual comparison (I liked the old one);
<em><small>(What can the Ruby Toolbox do better?)</small></em>

<!-- -->
> Sparklines for histories.
<em><small>(What can the Ruby Toolbox do better?)</small></em>

Yes! There's a [feature request for this on github, too](https://github.com/rubytoolbox/rubytoolbox/issues/126).

Earlier this year I did some research into a charting library that might fit the bill, but literally could not find any I was fully happy with. No wonder everybody creates their own charting libraries all the time :)

The charts absolutely must come back, I will look into this.

##### Dependency Weight

<!-- -->
> How heavy are the projects: LOC, dependencies etc.
<em><small>(Feature Requests)</small></em>

<!-- -->
> * Dependencies
> * "Used in" / "Known for"
<em><small>(Feature Requests)</small></em>

On the old site, reverse dependencies (projects depending on this library) were displayed. Currently, only the total number of them is shown. Seeing what specific projects are using a library as a dependency can be quite helpful as well though, so it might be nice to start mirroring them from the rubygems API again.

I really like the LOC idea. If we calculated those for each gem and combined it with the full dependency graph of a library it might make for some interesting additional metric in showing the total weight of the dependency you are adding.

#### Changelogs & Update Notifications

<!-- -->
> 1) Notifications on updates (ideally taking semver into account, like get only notifications on 1.x branch, not on 2.x).
> 2) To accompany 1): show whether project uses semver
<em><small>(Feature Requests)</small></em>

Changelogs were part of the feature vote, but didn't get a huge amount of votes. To my best knowledge these are fairly tough to acquire since there are no APIs to source them from. For example, finding the appropriate git tag for a version can already prove tough. Many projects use the "v1.0.0" scheme, but some do not, and some do not tag consistently or at all. Then extracting changelogs is tough, because they are frequently in an arbitrarily-formatted `CHANGELOG` file, and for "meta-gems" like rails or rspec the actual gem usually does not see any changes, they all live in the sublibraries.

So all in all, I'm not going to dive into this topic now. You might want to consider using automated dependency update services like [depfu](https://depfu.com/) (disclosure: I know the people who make this, and use it on the Toolbox ;) or [dependabot](https://dependabot.com/), which usually incorporate changelogs for updated dependencies automatically.

Regarding automated notifications please see what I wrote regarding community / social features above.

##### More metrics / data from other services

<!-- -->
> Also I wonder if for common badges/integrations such as codeclimate, travis/circle build status and others, we could adopt the badges into the site.
<em><small>(Feature Requests)</small></em>

<!-- -->
> I'd like to see code quality metric, it might help new projects arise
<em><small>(Feature Requests)</small></em>

<!-- -->
> Support for Gitlab repositories
<em><small>(Feature Requests)</small></em>

I'm not a big fan of badges themselves, I think they somewhat break the visual experience of a page, and once you have more than 3 nobody is able to find the relevant one anyway. However, it might be worthwile to investigate API integrations into popular services like Travis, Circle, or Code Climate for further metrics.

Regarding Gitlab (and other Git hosting providers for that matter): Currently, a total of 594 out of 148313 total ruby gems have a homepage or source code url set that contains "gitlab". The vast majority of the most downloaded ones come from repos owned by gitlab the company itself, so I think it's fair to say that it's a relatively niche subject at the moment.

The main "problem" with bringing in other git hosts that I see is that it would actually skew scores against the project's favor. Since for the ranking the Toolbox uses the highest watchers / forks count as the reference point, and considering the generally lower interaction rate on Gitlab, projects that have a reasonable amount of gem downloads would get downgraded because in relation they have much less stars than "they should" for their size. As long as such a significant portion of the open source community (both creators as well as consumers) orbits mostly around GitHub I don't think it's worth the additional effort to support other providers as plenty of the value derived from the metrics the Toolbox shows depend upon the "wisdom of the crowd".

##### Other feature requests

<!-- -->
> A Description or a list of every method exposes to the world and the return value from a gem.
<em><small>(Feature Requests)</small></em>

This is very tough to automate since there are no strong conventions into public / private API designation in the ruby ecosystem. I see this either in the responsibility of library docs themselves or documentation services like [rubydoc.info](https://www.rubydoc.info/)

<!-- -->
> Bunch of information about gems.
<em><small>(What can the Ruby Toolbox do better?)</small></em>

Not sure I understood this one correctly, but I do intend to write some documentation on why / how to pick libraries, as well as some guidance and pointers to relevant docs for maintainers on how to set up your projects best to work together well with the Ruby Toolbox.

<!-- -->
> tip to optimize the performance of each gem.
<em><small>(Feature Requests)</small></em>

Again, I don't see a way for Ruby Toolbox to do this in an automated manner, and I think library maintainers, Stack Overflow and bloggers already do a good job at this anyway.

<!-- -->
> Maybe user should also be gently guided to the right gem/system to integrate assets (JS/SASS through gems or webpacker or other)
<em><small>(What can the Ruby Toolbox do better?)</small></em>

I'm very hesitant about moving into "editorial content" realms, since it takes a lot of time to create the content in the first place, and to keep it fresh afterwards. However, it might be a good idea to provide more background on categories themselves within their descriptions. I added support for short category descriptions when I rebuilt the site last year, however very few descriptions have actually been contributed via PRs so far, so if you have some time please send some along :)

<!-- -->
> 3) show who sponsors which gem
<em><small>(Feature Requests)</small></em>

This is a very deep topic. In general the Ruby Toolbox has so far always taken a very "neutral" position here. Discussing how open source is funded probably goes way beyond the scope of this paragraph, but between enthusiasts loving to work on a specific a problem or building up their reputation, employees of tech companies solving a problem for themselves and open sourcing the code, companies and communities funding engineers to work on libraries, reduced-functionality open source with paid "enterprise" add-ons and commercial services that "open source" client libraries for interacting with their paid services, there's a huge variety of ways open source gets "sponsored". In order to somewhat dodge this bullet, the Toolbox focuses on what the community actually uses by it's regular ranking mechanism.

<!-- -->
> 4) show if a Code of Conduct is used
<em><small>(Feature Requests)</small></em>

Yes, we should have this, and GitHub apparently supports it in their API as well now.

<!-- -->
> 5) show which license is employed
<em><small>(Feature Requests)</small></em>

This is already part of the site, albeit only on the project details view, not on category overview pages.

<!-- -->
> Contract me.
<em><small>(Other)</small></em>

Thank you, however I'm sorry but this service is not run by a company ;)

### Closing notes

Many people also took the opportunity to say thanks for my work on this site. Thanks a lot for all your kind words, it fills me with great pride that I have made something that has proven useful to so many people in this community!

<!-- -->
> Thanks for all your work!!
<em><small>(Other)</small></em>

<!-- -->
> Keep it up. Great service.
<em><small>(Other)</small></em>

<!-- -->
> Keep up the good work!
<em><small>(Other)</small></em>

<!-- -->
> I've always loved the site. Keep up the good work.
<em><small>(Other)</small></em>

<!-- -->
> Thanks.
<em><small>(Other)</small></em>

<!-- -->
> Thank you for your work on this. This website is one of the best ways as a new or mid-level dev to discover which gems in the community have mindshare.
<em><small>(Other)</small></em>

<!-- -->
> This project is so helpful! Thank you so much! I really appreciate all your time and effort. When your big crash happened I was so sad and disappointed at the prospect of this resource going away. I'm thrilled that you've brought it back to life. Thank you thank you thank you!
<em><small>(Other)</small></em>

<!-- -->
> Thank you!
> Thank you!
> THANK YOU!
<em><small>(Other)</small></em>

<!-- -->
> Thanks for maintaining this!
<em><small>(Other)</small></em>

<!-- -->
> Appreciate the effort that went into and the valuable resource that is the ruby toolbox.
<em><small>(Other)</small></em>

<!-- -->
> Was very glad to see RT back online after the issues. Was sorely missed. RT is often used by us during the startup of a new project to re-familiarize ourselves with what libs/projects/gems are available and how they've changed. Also used during "spring cleaning" times on long-running RoR projects to update the gem file for the same reasons as stated above.
<em><small>(Other)</small></em>

<!-- -->
> I love the project, and I'm really happy that so many people helped get it back online when it hit a bump in the road! <3
<em><small>(Other)</small></em>

<!-- -->
> thanks very much for keeping this up.
<em><small>(Other)</small></em>

<!-- -->
> You are doing great work! It’s very important site for whole ecosystem of ruby, I’m senior dev but I would recommend to focus on beginners/norms devs to keep community in good shape
<em><small>(Other)</small></em>

<!-- -->
> Really appreciate your work on bringing back Ruby Toolbox. I look forward to seeing it become the place for gem discovery.
<em><small>(Other)</small></em>

<!-- -->
> Thanks, you are doing good job for ruby community.
<em><small>(Other)</small></em>

<!-- -->
> This tool helps me a lot each time I have to search for gems in a new area. Keep up the good work!
<em><small>(Other)</small></em>

<!-- -->
> Thanks, the site rocks! Been a huge help to me over the years.
<em><small>(Other)</small></em>

<!-- -->
> I’m already quite happy with what you do based on my needs =)
<em><small>(What can the Ruby Toolbox do better?)</small></em>

<!-- -->
> It's a wonderful toolbox !
<em><small>(What does the Ruby Toolbox do well?)</small></em>

<!-- -->
> You guys have been so great!
<em><small>(What can the Ruby Toolbox do better?)</small></em>

Ok, now on to some actual work, and please do stop by [the Ruby Toolbox chat room](https://gitter.im/rubytoolbox/Lobby) and say hi!

Best,<br/>
Christoph
