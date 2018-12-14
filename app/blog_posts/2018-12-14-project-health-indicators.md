# Project Health Indicators

In the [recent community survey](/blog/2018-12-04/survey-results) the **detection and flagging of unmaintained projects** turned out as the most-often requested feature.

To give you a better overview of the maintenance status of any project **from today on you can find a set of colored badges on each project that provide a visual indication of it's health** based on common properties like the time since the **last gem release, recent commit activity and open issue rates.**

<a href="https://user-images.githubusercontent.com/13972/50006036-af947500-ffac-11e8-9a9b-532676a194a4.gif"><img src="https://user-images.githubusercontent.com/13972/50006036-af947500-ffac-11e8-9a9b-532676a194a4.gif"></a>

The labels are of course based on the project metrics already shown, but by automatically interpreting the plain data into colored indicators I hope to provide you with an **easier indication of the health of a project without having to compare the plain values**.

I chose to use one year as the limit for yellow warnings and three years for red warnings. **However, this might not be fitting to all libraries. If you think an assessment is unfair or inaccurate, please [add your feedback on the original PR](https://github.com/rubytoolbox/rubytoolbox/pull/355) for this feature.** *(You may also add your feedback if you think it is very fair and accurate of course ;)*

You can also use the [PR](https://github.com/rubytoolbox/rubytoolbox/pull/355) to **propose additional health checks**. In that regard I'd like to take the opportunity to advertise the [daily database exports](/blog/2018-09-30/database-exports) - browsing the actual dataset can be very helpful in identifying new health checks, and **I hope we can add more of those over the next months**.

**The health indicators do not affect the project ranking for now** since I plan to look into possible improvements of the project scoring mechanism in the next weeks anyway.

In the last two weeks I **also made a lot of smaller improvements** and preparations for upcoming features, most notably I **[refined the appeareance of categories across the site](https://github.com/rubytoolbox/rubytoolbox/pull/350):**

<a href="https://user-images.githubusercontent.com/13972/50003992-e74bee80-ffa5-11e8-915d-2e11ea4cd3d9.gif"><img src="https://user-images.githubusercontent.com/13972/50003992-e74bee80-ffa5-11e8-915d-2e11ea4cd3d9.gif"/></a>

For more details please take a look at (and bring your feedback to) [the recent pull requests](https://github.com/rubytoolbox/rubytoolbox/pulls?q=is%3Apr+is%3Aclosed), I always try to provide a good overview of the purpose of each change in the pull request description.

Best,<br/>Christoph
