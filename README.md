DevFlow: ROADMAP/git based develop flow control
===================================================

Pre-alpha implementation for internal use only.

Pre-Requirement
-----------------

- A Bash command line console (cygwin is supported)
- A workable git installation and `git` command in the path
- Ruby 1.9.x

Work Flow
-------------

1. Write a `ROADMAP` file in a specified format
2. (Optional) create `members.yml` file define known developers
2. Run `dw` with sub-command 

Typical commands of the work flow are:

    $ dw [info]            # show task information

    $ dw progress 80       # mark the task as completed at 80 percent
    $ dw pg 80             # same as progress

    $ dw complete          # mark that the implemention is completed

    $ dw close             # this command is for project leader only, close the current task
                           # merge it into `develop` trunk and delete the git branch both 
                           # locally and remotely).

    $ dw release           # like close but for release branch only. 
                           # the change will be merged into both `develop` and `master` branch.

More commands may plug in later.

ROADMAP File Format
--------------------

The default task control file is `ROADMAP`, unless you specify an other file using 

    $ dw --roadmap OTHER_FILE

See more options by issue

    $ dw -h 

or

    $ dw --help

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
but you can define additional members in the header area too.

### Team and Leader

Leader has a higher priority than team members, only leader can edit roadmap, 
close a task branch, and make a release, etc.

If you also defines `supervisor`, `moderator`, they can also update the roadmap.

Generally you should use short names in team members to save typings, 
by define a `members.yml` file in the following format:

    members:
      short_name: [Display Name, 'email@address.com']

### Task Tree

Every line start with a `[+]` (or `[++]`, `[+++]` ...) will be treated as a task definition. 

A typical task definition line should following the format:

    [+] branch_name: taskname date/to/start[-date/to/stop] @resource[;resource] [-> dependent_on;dependent_on]

- `[+]` one or more + in bracket is the indicator of task definition, 
one + represent a 1st degree task, ++ represent a second degree task, .... 
Task with lower degree may contains several higher degree tasks.

- `branch_name` must contains only a-z, 0-9 and underscore, which is used as git branch name,
and also serves as a id for that task within the same ROADMAP file.

- `taskname` could use any characters provide not contains 'date like' parts.

- `date/to/start` should in format 2013/03/03 or 03/03 if you defined `year` in the 
header (so you can specify only the `mm/dd` part). 
Additionally, if the task duration is within one day, date/to/stop part can be omitted.

- `@resource`: resource should correspond to leader or one of the team member. 
If the task need more than one resources use ; to separate them.

- If the task depends on other task, puts their id after `->`.

### Git Branch Models

- `master`, `develop`, `staging` and `production` branches are **trunks**. Code modification
should done in non-trunk branches and merged into trunks according basic roles.

- The `master` trunk is a production ready branch, `develop` is the **integration** branch
that contains latest code of completed feature that passed integrate test.

- Development branches (**task branch**) should merge from `develop` often, and merged
back into `develop` trunk as soon as the implementation complete and passed all unit and 
integration tests.

- Release branches do not introduce new code but bug fix, after pass the QC tests, it 
release branches will be merged into `master` trunk.

### Semantic Versioning and Special Tasks

Tasks with branch name starts with `release_`, `bugfix_`, `hotfix_` ... 
will have special meanings. 

You use `release_` branch to manually manage major and minor versioning, 
e.g. `release_v0.1` will create a tag `version_0.1`, and bugfix, hotfix branches 
will add-up fix numbers after it such as: `version_0.1.28`. 

`milestone_` is a special type of task that corresponding to important event 
in the development flow but not reflects to version numbers 
(for example event for code review). 

Other tasks also do not affect version numbers.

Sometimes you may want to use 'prepare releases' such as `release_v0.1a`, `release_v0.1b`, 
avoid sandwich tasks between prepare releases and releases.

Local Configuration
---------------------

Default is stored in `.dev_flow` file and will be set to ignored by git 
(so these settings only affect your local working directory).

Without this file `dw` will go into the initialization mode (by asking you some questions).

You can use `--local-config FILE` to specify an other file.

`.dev_flow` is also in yaml format and the most important key is `whoami`, which corresponds 
to one of the leader or team members, indicates who is currently working on the local working
directory, and `git_remote` defines with git remote server to use (default is `origin`).

Command Details
-------------------

- `dw init` default command if no `.dev_flow` file found.

- `dw [info]` or `dw` without command will list the tasks and if the working directory 
is clean, let user chose which tasks to start with.

- `dw progress 0-99` set task progress. `dw pg` is an alias of progress.

- `dw complete` set task progress to 100 (complete a task), send to leader.

- `dw close`/`dw release` close the task by the leader, or release a release 
branch (to master trunk).

- `dw update-roadmap` or `dw ur` update the roadmap.

- `dw cleanup` will delete local branches corresponding completed tasks.

