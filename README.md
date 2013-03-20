DevFlow: ROADMAP/git based develop flow control
===================================================

Pre-Requirement
-----------------

- A Bash command line console (cygwin is supported)
- A workable git installation and `git` command in the path
- Ruby 1.9.x

Work Flow
-------------

1. Write a ROADMAP file in a specified format
2. Run `dw` command in directory contains the ROADMAP file (usually the root of you application)
   
    $ dw                   # show task informations
    $ dw start task_name   # start working on task_name at a specific branch
    $ dw progress 80       # mark the task is completed at 80 percent
    $ dw complete          # mark the implemention is complete
    $ dw close             # this command is for project leader only, he will close the current task,
                           # merge it into `develop` trunk and delete the task branch.
    $ dw release           # this is available if in a release branch and the current user is leader,
                           # the change will be merged into `master` branch with a new version number.

ROADMAP File Format
--------------------

The default task control file is `ROADMAP`, unless you specify an other file using 

### Information Header

Contents between two

    % ---

(with a head `%` and at least 3 dashes) lines and before any definition of task will be
treated as information header. Which should be in YAML format and should at least contains
`title`, `leader`, and `team`, like:

    % ---
    title: A Sample Project
    status: production 
    leader: sunyr
    team: [huangw xuyc]
    year: 2013
    % ---

If you define `year` in the header, you can write date in `mm/dd` format instead of `yyyy/mm/dd`.


### Team and Leader

Leader has a higher priority than team members such as edit roadmap, close a task branch, make a release, ...

If you also defines `supervisor`, `moderator`, they will also have the same priority of the leader
except make releases.

Generally you should use short names in team members to save typings, you can define a `members.yml` file
to define detail information about members:

    members:
      short_name: [Display Name, 'email@address.com']

You can define those member on header too, and if you defined both, the definition on header will over-write
the definition on yml file (use general merge).

### Task Tree

Every line start with a `[+]` (or `[++]`, `[+++]` ...) will be treat as a task definition. 

A typical task definition line should following the format:

    [+] branch_name: taskname date/to/start[-date/to/stop] @resource[;resource] [-> dependent_on;dependent_on]

- branch_name must in a-z, 0-9 and underscore, which used by git as branch names and also serves as a id for that task (so you should ensure no two tasks with the same name for the same ROADMAP).

- taskname could use any characters provide not contains 'date like' parts.

- date/to/start should in format 2013/03/03 or 03/03 if you defined `year` in the header you can specify only the `mm/dd` part. Additionally, if the task duration is within one day, date/to/stop part can also be omitted.

- @resource: `resource` should correspond to leader or one of the team member. If the task need more than one resources use ; to separate them.

- if the task depends on other task, puts their id after `->`. Dependencies are treat as an indicator only (for example show special colors in Gantt charts).

### Semantic Versioning and Special Tasks

Tasks with branch name starts with `release_`, `bugfix_`, `hotfix_` ... will have special means. 

`milestone_` is a special type of task that corresponding to important event in the development flow but
not reflects to the version (for example event for code review). 

Other tasks are under the `task_` name-space and have no versioning meanings.

You use `release_` branch to manage major and minor versioning, e.g. `release_v0.1` will create a tag 
`version_0.1`, And bugfix, hotfix branches will add-up fix numbers after it: `version_0.1.28`. 

Sometimes you may want to use 'prepare releases' such as `release_v0.1a`, `release_v0.1b`, avoid sandwich
hotfix and bugfix branch between prepare releases and releases.

Local Configuration
---------------------

Default is stored in `.dev_flow` file and will be set to ignored by git (so this setting is just for your local working directory).

Without the file dw will go into the initialization mode (by asking you some questions).

`.dev_flow` is also in yaml format and the most important key is `whoami`, which corresponds to one of the leader
or team members, indicates who is currently working on the local working directory.

Command Details
-------------------

- `dw init` default command if no `.dev_flow` file found.

- `dw [list]` list all tasks assigned to you, if you are the leader, all tasks will be listed. Or you can use `--all ` option or `--me` option or `--resource someone` to explicitly determine who's tasks to show.

- `dw start [branch_name]` start to working on a task (create a `task/branch_name` git branch).


