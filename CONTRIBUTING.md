# Contributing to pupil-analysis

:+1::tada: Thank you for considering contributing to pupil-analysis! :tada::+1:

The following is a set of guidelines for contributing to pupil-analysis. These are mostly guidelines, not rules. Use your best judgment, and feel free to propose changes to this document in a pull request.

#### Table Of Contents

[Code of Conduct](#code-of-conduct)

[I don't want to read this whole thing, I just have a question!!!](#i-dont-want-to-read-this-whole-thing-i-just-have-a-question)

[How Can I Contribute?](#how-can-i-contribute)
  * [Reporting Bugs](#reporting-bugs)
  * [Suggesting Enhancements](#suggesting-enhancements)
  * [Pull Requests](#pull-requests)

[Styleguides](#styleguides)
  * [Git Commit Messages](#git-commit-messages)
  * [MATLAB Styleguide](#matlab-styleguide)
  * [Documentation Styleguide](#documentation-styleguide)

[Additional Notes](#additional-notes)
  * [Issue and Pull Request Labels](#issue-and-pull-request-labels)

## Code of Conduct

This project and everyone participating in it is governed by the [pupil-analysis Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to [chips.devs@gmail.com](mailto:chips.devs@gmail.com).

## I don't want to read this whole thing I just have a question!!!

Questions can be asked via email to one of the developers or via opening an issue.
> **Note:** although the developers will endeavour to address all questions in a timely manner, this may not always be possible.

## How Can I Contribute?

### Reporting Bugs

This section guides you through submitting a bug report for pupil-analysis. Following these guidelines helps maintainers and the community understand your report :pencil:, reproduce the behavior :computer: :computer:, and find related reports :mag_right:.

Before creating bug reports, please check [this list](#before-submitting-a-bug-report) as you might find out that you don't need to create one. When you are creating a bug report, please [include as many details as possible](#how-do-i-submit-a-good-bug-report).

> **Note:** If you find a **Closed** issue that seems like it is the same thing that you're experiencing, open a new issue and include a link to the original issue in the body of your new one.

#### Before Submitting A Bug Report

* **First, check if you can reproduce the problem [in the latest version of pupil-analysis](https://github.com/EIN-lab/pupil-analysis/releases)**.
* **Perform a [cursory search](https://github.com/issues?q=+is%3Aissue+user%3AEIN-lab)** to see if the problem has already been reported. If it has **and the issue is still open**, add a comment to the existing issue instead of opening a new one.
* **Use MATLAB's debugging tools.** You might be able to find the cause of the problem and fix things yourself, i.e. already provide a solution to the problem.


#### How Do I Submit A (Good) Bug Report?

Bugs are tracked as [GitHub issues](https://guides.github.com/features/issues/). [Create an issue on the pupil-analysis repository](https://github.com/EIN-lab/pupil-analysis/issues)  with the `bug` label and provide the following information:

Explain the problem and include additional details to help maintainers reproduce the problem:

* **Use a clear and descriptive title** for the issue to identify the problem.
* **Describe the exact steps which reproduce the problem** in as much detail as possible.
* **Provide specific examples to demonstrate the steps**. Include links to files (particularly images) or copy/pasteable code snippets, which you use in those examples. If you're providing snippets in the issue, use [Markdown code blocks](https://help.github.com/articles/markdown-basics/#multiple-lines).
* **Describe the behavior you observed after following the steps** and point out what exactly is the problem with that behavior.
* **Explain which behavior you expected to see instead and why.**
* **Include screenshots and animated GIFs** which show you following the described steps and clearly demonstrate the problem. You can use [this tool](http://www.cockos.com/licepupil/) to record GIFs on macOS and Windows, and [this tool](https://github.com/colinkeenan/silentcast) or [this tool](https://github.com/GNOME/byzanz) on Linux.
* **If the problem wasn't triggered by a specific action**, describe what you were doing before the problem happened and share more information using the guidelines below.

Provide more context by answering these questions:

* **Did the problem start happening recently** (e.g. after updating to a new version of pupil-analysis) or was this always a problem?
* If the problem started happening recently, **can you reproduce the problem in an older version of pupil-analysis?** What's the most recent version in which the problem doesn't happen? You can download older versions of pupil-analysis from [the releases page](https://github.com/EIN-lab/pupil-analysis/releases).
* **Can you reliably reproduce the issue?** If not, provide details about how often the problem happens and under which conditions it normally happens.
* If the problem is related to working with files, **does the problem happen for all files or only some?** Does the problem happen only when working with files of a specific type or with large files? Is there anything else special about the files you are using?

Include details about your configuration and environment:

* **Which version of pupil-analysis are you using?**
* **What's the name and version of the OS you're using?**
* **Are you running MATLAB in a virtual machine?** If so, which VM software are you using and which operating systems and versions are used for the host and the guest?
* **Do you use local modification of the original pupil-analysis code?**

### Suggesting Enhancements

This section guides you through submitting an enhancement suggestion for pupil-analysis, including completely new features and minor improvements to existing functionality. Following these guidelines helps maintainers and the community understand your suggestion :pencil: and find related suggestions :mag_right:.

Before creating enhancement suggestions, please check [this list](#before-submitting-an-enhancement-suggestion) as you might find out that you don't need to create one. When you are creating an enhancement suggestion, please [include as many details as possible](#how-do-i-submit-a-good-enhancement-suggestion).

#### Before Submitting An Enhancement Suggestion

* **Update** to the [latest version of pupil-analysis](https://github.com/EIN-lab/pupil-analysis/releases) — you might discover that the enhancement is already available.
* **Perform a [cursory search](https://github.com/issues?q=+is%3Aissue+user%3AEIN-lab)** to see if the enhancement has already been suggested. If it has, add a comment to the existing issue instead of opening a new one.

#### How Do I Submit A (Good) Enhancement Suggestion?

Enhancement suggestions are tracked as [GitHub issues](https://guides.github.com/features/issues/). [Create an issue on the pupil-analysis repository](https://github.com/EIN-lab/pupil-analysis/issues) with the `enhancement` label and provide the following information:

* **Use a clear and descriptive title** for the issue to identify the suggestion.
* **Provide a step-by-step description of the suggested enhancement** in as much detail as possible.
* **Provide specific examples to demonstrate the steps**. Include copy/pasteable snippets which you use in those examples, as [Markdown code blocks](https://help.github.com/articles/markdown-basics/#multiple-lines).
* **Describe the current behavior** and **explain which behavior you expected to see instead** and why.
* **Include screenshots and animated GIFs** which help you demonstrate the steps or point out the part of pupil-analysis which the suggestion is related to. You can use [this tool](http://www.cockos.com/licepupil/) to record GIFs on macOS and Windows, and [this tool](https://github.com/colinkeenan/silentcast) or [this tool](https://github.com/GNOME/byzanz) on Linux.
* **Explain why this enhancement would be useful** to pupil-analysis users.
* **Cite, if applicable, other software using the suggested enhancement.**
* **Specify which version of pupil-analysis you're using.**
* **Specify the name and version of the OS you're using.**

### Pull Requests

* Include screenshots and animated GIFs in your pull request whenever possible.
* Follow the [MATLAB Styleguide](#matlab-styleguide).
* Include tests and checks to make sure the newly contributed functionality can handle as many exceptions you can think of.
* Document new code based on the [Documentation Styleguide](#documentation-styleguide)
* Avoid platform-dependent code.

## Styleguides

### Git Commit Messages

* Use the present tense ("Add feature" not "Added feature")
* Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
* Limit the first line to 72 characters or less
* Reference issues and pull requests liberally after the first line
* Consider starting the commit message with an applicable emoji:
    * :art: `:art:` when improving the format/structure of the code
    * :racehorse: `:racehorse:` when improving performance
    * :non-potable_water: `:non-potable_water:` when plugging memory leaks
    * :memo: `:memo:` when writing docs
    * :penguin: `:penguin:` when fixing something on Linux
    * :apple: `:apple:` when fixing something on macOS
    * :checkered_flag: `:checkered_flag:` when fixing something on Windows
    * :bug: `:bug:` when fixing a bug
    * :fire: `:fire:` when removing code or files
    * :white_check_mark: `:white_check_mark:` when adding tests

### MATLAB Styleguide

pupil-analysis does not currently follow a detailed styleguide, but please follow
the style of existing code in any new contributions, where possible.

### Documentation Styleguide

Please ensure any new contributions are documented sufficiently.  This
includes both developer level documentation, within the code, to make it
easy to follow, and also user level documentation.  Functions, methods
or properties that are not user-facing are not required to be documented
to the same level as public facing ones, but must still be understandable
to the developers.

#### Example

```MATLAB
function [argout, optargout]  = foo(argin, optargin)
%foo - Run example function
%
%	ARGOUT = foo(ARGIN) ...
%
%	ARGOUT = foo(ARGIN, OPTARGIN) ...
%
%	[ARGOUT, OPTARGOUT] = foo(...) ...
%
%	See also bar

%   Copyright (C) 2018  Zoe J. Looser et al.
%
%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/>.

% ======================================================================= %

% <Place initial checks here>

% ----------------------------------------------------------------------- %

% <Place actual processing here>

end

```

## Additional Notes

### Issue and Pull Request Labels

This table lists the labels we use to help us track and manage issues and pull requests. [GitHub search](https://help.github.com/articles/searching-issues/) makes it easy to use labels for finding groups of issues or pull requests you're interested in. To help you find issues and pull requests, each label is listed with search links for finding open items with that label in `EIN-lab/pupil-analysis`. We encourage you to read about [other search filters](https://help.github.com/articles/searching-issues/) which will help you write more focused queries.

| Label name | `pupil-analysis` :mag_right: | Description |
| --- | --- | --- |
| `enhancement` | [search][search-pupil-analysis-repo-label-enhancement] | Feature requests. |
| `bug` | [search][search-pupil-analysis-repo-label-bug] | Confirmed bugs or reports that are very likely to be bugs. |
| `question` | [search][search-pupil-analysis-repo-label-question] | Questions more than bug reports or feature requests (e.g. how do I do X). |
| `duplicate` | [search][search-pupil-analysis-repo-label-duplicate]  | Issues which are duplicates of other issues, i.e. they have been reported before. |
| `help wanted` | [search][search-pupil-analysis-repo-label-help-wanted] | The pupil-analysis core team would appreciate help from the community in resolving these issues. |
| `wontfix` | [search][search-pupil-analysis-repo-label-wontfix] | The pupil-analysis core team has decided not to fix these issues for now, either because they're working as intended or for some other reason. |
| `invalid` | [search][search-pupil-analysis-repo-label-invalid] | Issues which aren't valid (e.g. user errors). |

[search-pupil-analysis-repo-label-enhancement]: https://github.com/issues?q=is%3Aopen+is%3Aissue+repo%3AEIN-lab%2Fpupil-analysis+label%3Aenhancement
[search-pupil-analysis-repo-label-bug]: https://github.com/issues?q=is%3Aopen+is%3Aissue+repo%3AEIN-lab%2Fpupil-analysis+label%3Abug
[search-pupil-analysis-repo-label-question]: https://github.com/issues?q=is%3Aopen+is%3Aissue+repo%3AEIN-lab%2Fpupil-analysis+label%3Aquestion
[search-pupil-analysis-repo-label-help-wanted]: https://github.com/issues?q=is%3Aopen+is%3Aissue+repo%3AEIN-lab%2Fpupil-analysis+label%3Ahelp-wanted
[search-pupil-analysis-repo-label-duplicate]: https://github.com/issues?q=is%3Aopen+is%3Aissue+repo%3AEIN-lab%2Fpupil-analysis+label%3Aduplicate
[search-pupil-analysis-repo-label-wontfix]: https://github.com/issues?q=is%3Aopen+is%3Aissue+repo%3AEIN-lab%2Fpupil-analysis+label%3Awontfix
[search-pupil-analysis-repo-label-invalid]: https://github.com/issues?q=is%3Aopen+is%3Aissue+repo%3AEIN-lab%2Fpupil-analysis+label%3Ainvalid

## Attribution

These contributing guidelines are derived from [atom.io](https://atom.io)'s [CONTRIBUTING.md](https://github.com/atom/atom/blob/master/CONTRIBUTING.md), which is licensed under the [MIT License](https://github.com/atom/atom/blob/master/LICENSE.md).
