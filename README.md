# GIT static builder

[![GIT static builder](https://github.com/TheCBaH/git.builder/actions/workflows/build.yml/badge.svg?branch=master)](https://github.com/TheCBaH/git.builder/actions/workflows/build.yml)

Scripts to build GIT binaries of various versions, statically linked with MUSL libc.

## Get started
* [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new?hide_repo_select=true&ref=master&repo=618694014)
* Native
  * `make repo`
  * `make git.configure`
  * `make git.build`
  * `make git.test`
* Alpine - git static binaries
  * `make alpine.image`
  * `make repo`
  * `./with-docker alpine make curl WITH_STATIC=1`
  * `./with-docker alpine make git.configure WITH_STATIC=1`
  * `./with-docker alpine make git.build`
  * `./with-docker alpine make git.test`
  * `make git.test`
