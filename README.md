DevFlow: ROADMAP/git based development flow control
=====================================================

WARNING: Pre-alpha implementation for internal use only.

Requirement
------------------

- A Bash compatible console (cygwin is supported)
- A workable git installation and `git` command in the path
- Ruby 1.9.x

Install
-----------

    $ [sudo] gem install dev_flow 

Work Flow
-------------

Under your git working directory:

1. Write a `ROADMAP` file in a specified format
2. (Optional) create `members.yml` file define known developers
2. Run `dw` command 

Sub-commands for typical work flow jobs are:

    $ dw [info]            # show task information

    $ dw switch [branch]   # switch to branch, or list workable branches to switch to
    ($ dw s [branch]       # alias of switch)

    $ dw progress 80       # mark the task as completed at 80 percent
    ($ dw pg 80            # same as progress)

    $ dw complete          # mark that the implemention is completed

    $ dw close             # this command is for project leader only, it will 
                           # mark the current task closed, merge it into `develop` trunk
                           # and delete the git branch both locally and remotely.

    $ dw release           # like close but for release branch only. the change will
                           # be merged into both `develop` and `master` branch.

More commands may plug in later.

ROADMAP File Format
--------------------

The default task control file is `ROADMAP`, unless you specify an other file using 

    $ dw --roadmap OTHER_FILE

See more options by issue

    $ dw -h 

(or `dw --help`)

### Information Header

Contents between two

    % ---

(with a head `%` and at least 3 dashes) lines and before any definition of task will be
treated as information header. Which should be in YAML format and should at least contains
`title`, `leader`, and `team`, like:

    % ---
    title: A Sample Project
    status: producing
    members:
      qsh: [Qin Shihuang, 'qsh@qinchao.com']
    leader: sunyr
    team: [huangw xuyc]
    year: 2013
    % ---

If you define `year` in the header, you can write date in `mm/dd` format instead 
of `yyyy/mm/dd`. Usually you should define developers in a separate `members.yml` file,
but you can define extra members in the header area too (usually for who only join to
one or few projects).

### Team and Leader

Leader has a higher priority than team members, only leader can edit roadmap, 
close a task branch, and make a release, etc.

If you also defines `supervisor`, `moderator`, they can update the roadmap too,
but can not close or release a branch.

IMPORTANT: those kind of permission is just introduced for avoid miss operation,
NOT intended as a security mechanism. You still needs setup permissions on your
remote git server if security is a concern.

Generally you are encouraged to use short names in team members to save typings, 
by define a `members.yml` file in the following format:

    members:
      short_name: [Display Name, 'email@address.com']

This is also a way to avoid typos in ROADMAP definitions.

### The Task Tree

Every line start with a `[+]` (or `[++]`, `[+++]` ...) will be treated as a task definition. 

A typical task definition line should following the format:

    [+] branch_name: taskname date/to/start[-date/to/stop] @resource[;resource] [-> dependent_on;dependent_on]

- `[+]` one or more + in bracket is the indicator of task definition, 
one + represent a 1st degree (level) task, ++ represent a second degree task, .... 
Task degree with smaller number may contains several tasks with higher degree number.

- `branch_name` must contains only a-z, 0-9, dot and underscore, which is used as git branch name,
and also serves as a id for that task within the same ROADMAP file.

- `taskname` could use any characters provide not contains 'date like' parts (see the next description).

- `date/to/start` should in format 2013/03/03 or 03/03 if you defined `year` in the 
header (so you can specify only the `mm/dd` part). Use `mm/dd-mm/dd` (`yyyy/mm/dd-yyyy/mm/dd`) 
to specify a period.

If the task duration is within one day, date/to/stop part can be omitted.

- `@resource`: resource should correspond to leader or one of the team member. 
If the task need more than one resources use ; to separate them.

- If the task depends on other task, puts their id after `->`.

### Git Branching Models

- `master`, `develop` branches are **trunks**. 

You should modify code only in non-trunk branches and merge your change into trunks 
according the following roles.

- The `master` trunk is a production ready branch, `develop` is the **integration** branch
that contains latest code of completed feature that _passed_all_integration_ test.

- You write programs under **task branches** that created from `develop`. You should 
use `dw` often to merge newest changes from `develop` trunk.

Ensure all tests pass before you `dw complete` your branch.

### Semantic Versioning and Special Tasks

Tasks with branch name starts with `release_`, `hotfix_` ... 
will affect the version number. 

You use `release_` branch to manually manage major and minor versioning, 
e.g. `release_v0.1` will create a tag `version-0.1`, and hotfix branches 
will add-up fix numbers after it such as: `version-0.1.28`. All those 
branches will merged into `master` trunk.

`milestone_` is a special type of task that corresponding to important event 
in the development flow (for example event for team code review, 
customer acceptance review, etc.), but do not affect version numbers, so do other tasks.

Sometimes you may want to use 'prepare releases' such as `release_v0.1a`, `release_v0.1b`, 
avoid sandwich tasks between prepare releases and releases.

Local Configuration
---------------------

Default is stored in `.dev_flow` file and will be set to `git`'s ignore list (`.gitignore`) 
(so these settings only affect your local working directory).

Without this file `dw` will go into the initialization mode (by asking you some questions).

You can use `--local-config FILE` to store those information in an other file name.

`.dev_flow` is also in yaml format and the most important key are `whoami` and `git_remote`,
`whoami` specifies who is currently working on the local working directory, 
and `git_remote` defines witch git remote server to use (default is `origin`).
With out `git_remote` the `dw` command will not try to communicate to remote git server.

If `git_remote` defined, `dw` command will try to sync with the remote git server,
unless you explicitly specify `--offline` (`-o`) option.

Command Details
-------------------

- `dw init` default command if no `.dev_flow` file found.

- `dw [info]` or `dw` without command will list tasks. If `git_remote` defined, it will
try to merge newest changes from remote git server (from your branch and `develop` trunk).

- `dw switch [branch]` will list a workable branches to choose to switch to. If current
branch is `develop`, `switch` is the default command.

- `dw progress 0-98` set task progress. `dw pg` is an alias of `dw progress`. You are
encouraged to frequently use this command to store you changes to remote servers (typically 
several times a day).

- `dw complete` set task progress to 99 (complete a task), urge the leader to review/test and
close it.

- `dw close`/`dw release` close the task by the leader, or release it (to master trunk).

- `dw update-roadmap` or `dw ur` used for update the roadmap (should only be used on `devleop` trunk).

- `dw cleanup` will delete local branches corresponding completed tasks.

