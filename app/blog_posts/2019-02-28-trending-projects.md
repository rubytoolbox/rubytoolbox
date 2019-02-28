# Trending Projects

**Discovery of new & trending projects** came in 2nd place behind the [
Detection and flagging of unmaintained projects](/blog/2018-12-14/project-health-indicators) in the [recent community survey][survey]. In that regard today I'm **happy to introduce [trending projects](/trends)**.

The **overall goal** was to **identify libraries that already have some sustained traction while still growing**:

<a href="/trends"><img src="https://user-images.githubusercontent.com/13972/53574089-2cc49480-3b6f-11e9-8085-568d2ead4d24.png"></a>

This feature is **based on the [recently](/blog/2019-02-25/historical-gem-download-charts) added [historical rubygem download data](/pages/docs/features/historical_rubygem_download_data)**.

I'd love to describe the elaborate uses of machine learning techniques used to build the feature but it's simply **based on recent Rubygem download rates and their growth**, with the query **tweaked until the results seemed consistent and reasonable to me**. If you're **interested in specifics** or **would like to suggest improvements** please take a look at the **[query on GitHub](https://github.com/rubytoolbox/rubytoolbox/blob/532373ba54097541d0d4965863c7e43273acb684/app/jobs/rubygem_trends_job.rb#L34-L42)**, **[the feature's documentation page][docs]** or the **[original pull request][PR]**.

---

Today's release **also marks the end of my time working on the Ruby Toolbox as my main project** that I **[began in last December](/blog/2018-11-05/community-survey) thanks to [Ruby Together's](https://rubytogether.org/) ongoing funding of my work on this site**. I will of course **continue maintaining the site and adding improvements**, but the
recent activity spike ends today as I begin a new freelance project soon.

To **close things properly** I will **follow up with a look back at the goals set based on [December's community survey results][survey] within the next two weeks**, but I'd already like to say a **big thank you to [Ruby Together](https://rubytogether.org/) for their support** and **sincerely hope that my recent work on the Ruby Toolbox has helped to make it more useful to you**!

Best,<br/>Christoph


[PR]: https://github.com/rubytoolbox/rubytoolbox/pull/449
[survey]: /blog/2018-12-04/survey-results
[docs]: /pages/docs/features/trending_projects
