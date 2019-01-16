# Bugfix Fork Detection & Filtering

Improvements to **search result relevance** were another big topic in the [recent community survey](/blog/2018-12-04/survey-results). In that regard today I'd like to introduce the **[detection of bugfix forks][docs]**.

Bugfix forks are **patched variants of popular gems**, usually from a time **before [bundler](/projects/bundler) made it very easy** to **switch a gem source to a patched git repo branch** while waiting for the fix to be merged and released upstream.

They usually have **very few downloads** and **only a single release**, long in the past - however, they often **still link the very popular upstream github repo**, leading to a **very high toolbox popularity score**. Now, since the **score affects the search result order**, for popular keywords the **top results** used to be **full of those forked gems**.

Based on what I observed on those libraries I **[added logic to detect those bugfix forks][Logic-PR]** and **[excluded them by default from search results][UI-PR]**, with a toggle button to re-enable display.

To **illustrate how this affects search results**, here's the **[top 10 search results for the term "authentication"](/search?q=authentication) before this change and afterwards**, with the default of filtered bugfix forks (Rubygem downloads in parentheses).

| **Before**                             | **Now**                                    |
|------------------------------------|------------------------------------------|
| devise (*43168395*)                | devise (*43168395*)                      |
| graffititracker_devise (*2662*)    | warden (*43948376*)                      |
| cloudfoundry-devise (*3560*)       | omniauth (*26476271*)                    |
| shingara-devise (*4833*)           | mixlib-authentication (*10410063*)       |
| devise-no-session (*365*)          | ruby-hmac (*11883122*)                   |
| upstream-devise (*997*)            | ntlm-http (*8837767*)                    |
| mongoid-devise (*3097*)            | koala (*6816462*)                        |
| namxam-devise (*1403*)             | authlogic (*3591583*)                    |
| rmello-devise (*2280*)             | net-http-digest_auth (*10186524*)        |
| loyal_devise (*12907*)             | rubyntlm (*10124188*)                    |

On top of that **[search results now finally have pagination][pagination-PR]**. Together with the **[recently launched project sorting](/blog/2019-01-09/project-sorting)**, these three changes will hopefully bring a **significant improvement to your Ruby Toolbox search experience**:

<a href="https://github.com/rubytoolbox/rubytoolbox/pull/380"><img src="https://user-images.githubusercontent.com/13972/51126093-92103080-1822-11e9-8971-c7d32fb1c327.gif"></a>

This feature **also brings the first [feature documentation page][docs]**. [As mentioned before](/blog/2019-01-09/new-landing-page) I want to work more on this topic in the next weeks to make the site's features easier to understand and accessible.

As usual if you'd like to give feedback on this a great place for that is the [Pull Request][UI-PR] of the feature.

Best,<br/>Christoph


[Logic-PR]: https://github.com/rubytoolbox/rubytoolbox/pull/377
[pagination-PR]: https://github.com/rubytoolbox/rubytoolbox/pull/375
[UI-PR]: https://github.com/rubytoolbox/rubytoolbox/pull/380
[docs]: /pages/docs/features/bugfix_forks
