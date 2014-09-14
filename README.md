# Project Develop Flow Management Tool Based on Git

WARNING: UNDER DEVELOPING, NOT COMPLETED

## Concept

Provide convenient command to guide development flow like
[git flow](https://github.com/nvie/gitflow).

Gather project information from the source files and render
those information to standard format (such like json) and a
static project portal (use html and css files).

- Better command line interface and yard documentation
- Separated data structure for Project, Project Member (and SLM), Task, ...
- Support RFC and Packing List, better change log and roadmap
- Git-flow compatible branch naming and sub command
- Better handle for merge failure
- Ability to sync with Local/Gitlab services

## Synopsis

- Configuration such as `whoami` (current user short name), use git config tool
  to store it in global or local space.

  `dw config` will show and set those configurations in git syntax.

- Parse `ROADMAP.md` (new markdown compatible ROADMAP format) for project
  information, RFC/Tasks. Load RFC/Tasks definition from any other source files.

  Load project information from `gitlab` or any local file.

- Project information (with members list), read-only (edit inside ROADMAP):

  `dw project`

- List tasks: `dw list`

- Current task information `dw`

- Progress management `dw pg <percentage>`
