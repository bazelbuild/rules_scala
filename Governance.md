# Governance of rules_scala
[bazelbuild/rules_scala](https://github.com/bazelbuild/rules_scala) is under the [bazelbuild](https://github.com/bazelbuild) org but is governed by contributors from the community.  
## Goals of this document
To clarify:  
1. Values of the project.  
2. How to get a PR merged  
3. How long you should need to wait for a review  
4. How to resolve conflicts in project direction  
5. How to make larger and potentially disruptive changes  
## Values of rules_scala
1. **Correctness**: Bazel values fully reproducible builds which are reliable and hermetic (only depend on the current state of your repository).  
2. **Speed**: we want to build as fast as possible. In a large repository, we believe the caching, parallelism and remote builds are critical and essential ways to achieve this. Without correctness, we can't cache and use remote builds, so correctness enables speed. We will almost never trade off correctness for speed.  
3. **Usability**: we want it to be as easy as possible to adopt and to maintain a build with these rules. However, in the pursuit of usability, we cannot sacrifice correctness or speed. We will seek to implement the best tools and methods and avoid shortcuts when creating first class support in Bazel for Scala. Usability includes stability: we aim to minimize breaking changes. We will prefer to keep some legacy or deprecated methods than force users to constantly make changes to keep their builds on the latest version of the rules. At the same time advancement and evolution of the rules_scala and the bazel ecosystem will require at some points to have breaking changes. We aim to have that process be better defined.  
4. **Maintainability**: we will keep up with Bazel best practices, update the codebase as Bazel evolves, and prevent the codebase from being hard to change. We believe that if we keep the codebase easier to work on, it is more likely to be worked on.  
5. **Accessibility**: we want this ruleset to be adopted and used by many throughout the Scala ecosystem. When users move to adopt the rules, we will be welcoming and helpful to them doing so. If their use case requires small, non-breaking changes to the rule set, we will try to help them make them. If their use case requires broader changes we will consider that as well. To be clear Accessibility is the lowest priority value since we’ve seen too many projects try to aim too wide and then have a hard time advancing forward. In addition the people and organizations who contribute to this ruleset have limited time and resources and cannot allocate it indefinitely to help adoption, this needs to be a mutual effort and with reasonable costs.  
## How to make a PR
We welcome pull requests and do all development in the open.   
* Pull requests should be in the smallest testable units possible. Ideally, a PR is fewer than 400 lines of change, but we understand in some cases it may be more. If your PR is much larger than normal, we may ask you to split it into smaller changes. For big changes, it’s usually a good idea to follow the [Proposing Designs](#proposing-designs) workflow at first, to ensure you’re working in the right direction.
* We think that automated testing is vital to ensure quality. To that effect, any meaningful change or fix should also include additional / modified tests that will run in CI.
* Your PR will be assigned a maintainer responsible for providing feedback automatically, there is no need to ping individual maintainers. That maintainer will try to provide feedback in a timeframe consistent with the “Accessibility” point above.
* Your PR _may_ be ignored if it has a red CI. It is your responsibility to get your PR green, or to ask for clarification if you doubt a test failure is due to your change.
* PRs should have a linear history (no intermediate merges) and meaningful comment messages. Long living PRs should be regularly rebased on the main branch.
* You will probably get feedback or requests for changes to your Pull Request. This is a big part of the submission process so don't be discouraged! Some maintainers may approve the Pull Request right away, others may have more detailed comments or feedback. This is a necessary part of the process in order to evaluate whether the changes are correct and necessary. We welcome code review by anyone: you don't need to be a maintainer to offer your review.
### Hard criterias for merging a PR:
1. The PR must pass the CI (Continuous Integration) test runs. 
2. Approval of at least 2 maintainers. One maintainer approval is enough if PR has been open for more than 7 days.
3. No blocking objection from any maintainer. PR should generally stay open for at least 2 business days to allow sufficient time to review.
### Disagreements by maintainers
* When there are disagreements by maintainers that cannot be settled in a PR discussion - we will use synchronous communication (preferred video chat with note taking) scheduled when 3/4 or more of the maintainers can make it. 
* After the synchronous communication we will choose a course of action. 
* If we cannot all agree, if 2/3 or more support merging a change, it will be done, otherwise we bias to no-merge. To clarify 2/3 relates to 2/3 from all maintainers and not only 2/3 from those who participated in the call. This goes hand in hand with a maintainer’s ability to “cast” a vote remotely (given scheduling conflicts etc). 
 
## Reporting bugs
We welcome bug reports and aspire to create an environment in which bug fixes are easy to contribute. There is currently no one paid to fix bugs that have been filed, so patience and direct contributions are greatly appreciated. The contributors and maintainers are happy to help coach prospective contributors in fixing bugs.  

If you find unexpected behavior, please reach our slack channel to discuss it and agree on the best path forward. If you’re sure the behavior is a bug, feel free to open a GitHub Issue following the guidelines below.  

An ideal bug report should include an issue filed in GitHub that is linked to a corresponding PR that adds a failing test to the repo. That way: we can track the issue and have an automated way of knowing we fixed it, this also allows us to protect against future regressions.  
## Proposing designs
For any change to design or the code that will span many PRs, we recommend submitting a PR containing an md file that outlines the planned change. In case Github markdown is not suitable for describing the change - one can use public Google doc, and share the public link to the PR context. We can then discuss the change on that PR. When there is a consensus, we can open a series of issues to track various portions of the work.  

We will have a designs.md which will serve as an index of accepted/completed/in-discussion/rejected designs.
## Maintainers
Maintainers must be the most active contributors to the repo. Generally maintainers contribute code to the repo, but the primary responsibility of the role is to support community contributions by reviewing, commenting on repo issues and PRs. Being a maintainer is not an honorific, but a responsibility to keep the project active and useful for a broad base of Scala and Bazel users.
### Reviewing and commenting on PRs and issues
1. We want users and contributors of the repo to feel like this repo is healthy and has a decent heartbeat. 
2. This can be achieved if maintainers will comment on PR and issues within reasonable time (up to 1 week and aim as much as possible to 24 hours). 
3. There are a lot of ways this responsibility can be handled (ownership areas, dedicated oncall etc.) The maintainers should decide together what is the best way for it to be done periodically and every time a new maintainer joins in.

Being a maintainer is a responsibility to review _each_ PR that is submitted within 2-3 business days. Maintainers should be advocates for the many current users as well as for the goal of improving the rules for future users. We want to give a high quality of service to PRs to encourage more contribution from the community. Maintainers are encouraged to ask input from other maintainers or Bazel community members.
 
### Becoming a maintainer
Maintainers are selected by 2/3 or more approval of the current set of maintainers. Any maintainer who has served for more than 6 months may propose new maintainers. A maintainer is expected to keep a decent level of responsiveness. In case the maintainer is not responsive in any channel for over 7 days for a certain discussion or question - their vote will be disregarded. If the maintainer has not been responsive for over 2 months and has not informed any other maintainer of a planned absence - they can be removed by other maintainers by a 2/3 or more approval. Changing the rules of this document requires a 2/3 or more approval of the current maintainers.


#### Current maintainers: (edit as needed)  
Ittai Zeidman, @ittaiz  
#### Past maintainers:  
Oscar Boykin, @johnynek  


