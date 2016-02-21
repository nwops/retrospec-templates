 [![Build Status](https://travis-ci.org/nwops/retrospec-templates.png)](https://travis-ci.org/nwops/retrospec-templates)

# Retrospec Templates
This repo is used to house all the templates and files that retrospec-puppet uses when creating or updating the module contents. The templates are separate from the gem in case you want to change them or have multiple template repos for different clients or situations.

## Usage
These templates are for use with the Retrospec puppet plugin tool (https://github.com/nwops/puppet-retrospec)
You can clone these templates yourself, but retrospec by default will clone this repo automatically.  There is nothing you need to do.

Should you want to use your own fork of these templates, you can specify the `scm-url` to point to whatever SCM repo. I have specifically designed retrospec to not depend on any one single SCM.  However, the hooks contained in this repo only work with git.  So you will need to make your own clone hook to suit other SCM types.

```
% retrospec puppet -h
Generates puppet rspec test code based on the classes and defines inside the manifests directory.
  -m, --module-path=<s>         The path (relative or absolute) to the module directory (Defaults to current directory)
  -t, --template-dir=<s>        Path to templates directory (only for overriding Retrospec templates) (default: /Users/cosman/.retrospec_templates)
  -s, --scm-url=<s>             SCM url for retrospec templates
  -b, --branch=<s>              Branch you want to use for the retrospec template repo
  -e, --enable-beaker-tests     Enable the creation of beaker tests
  -n, --enable-future-parser    Enables the future parser only during validation
  -v, --version                 Print version and exit
  -h, --help                    Show this message

retrospec -s https://github.com/nwops/retrospec-templates.git -b master -t ~/my_special_templates

```

## Configuration
The retrospec puppet plugin allows you to set some configuration settings that control how retrospec is run. While this is not an complete list of settings you may want to change where retrospec gets its puppet templates from.

```yaml
# ~/.retrospec/config.yaml
---
plugins::puppet::template_dir: '/Users/user1/retrospec-templates'
plugins::puppet::templates::url: 'https://github.com/nwops/retrospec-templates.git'
plugins::puppet::templates::ref: master
plugins::puppet::author: 'Corey Osman'
plugins::puppet::namespace: 'NWOPS'
```

## Hooks
Hooks are feature use to perform additional puppet module development automation. These hooks come pre-populated with some basic magic, but are intended to be changed to suit your development workflows.  Make sure your hooks have the executable bit set otherwise retrospec cannot execute them.

By default these hooks were programmed using Ruby and Bash but you are free to use any language as long as your script is executable.

See the clone-hooks feature set for a list of functions they provide.

## Clone-hook
This hook is called at the initialization time when running Retrospec.  Its primary use is to seed the templates that are used to retrofit your module.  By default the hook will clone from https://github.com/nwops/retrospec-templates.git.
However, this behavior can be changed by using the `-s` switch from retrospec or by changing the default url in the hook code.  The clone-hook that comes with the retrospec puppet plugin will bootstrap your machine with the proper templates. After the templates exist on your machine the clone-hook will be run from this repo only so that you can have full control over all the hooks and templates.

If you just want to change the location of the templates, update your config file instead of changing the clone hook.

### Features
  * clones or updates the retrospec templates passed in via the command line or config file
  * sets up a ssh config to use a control master for ssh connection reuse for github.com

## Pre-hook
This hook is called after the clone hook and before retrospec creates the files in your module.  Its useful for performing additional development workflows like setting up git hooks inside a persons module directory.  Because some tasks cannot be saved in this repository you can utilize the pre-hook to set up these items each time retrospec is called.  By default this hook will clone the [repo](https://github.com/drwahl/puppet-git-hooks) inside ~/.retrospec/repos and create a symlink to the pre-commit hook to the templates modules_files/.git/hooks/pre-commit.  What this does is ensure all your puppet modules automatically test code before committing based on the pre-commit hook code. This alone will hopefully save you 10 minutes for each use.

### Features
  * Clones or updates https://github.com/drwahl/puppet-git-hooks.git to   ~/.retrospec/repos/puppet-git-hooks
  * Sets the git pre-commit hook to use puppet hooks in the above repo

## Post-hook
This hook is called after creating the files in your module.  It can also be use to setup scm hooks.  If you find a good use case with the post-hook let me know as its just another hook to be called.  Maybe you can use this hook to set a running tabulation of how much time you saved using retrospec.

This hook currently does not do anything.

## Forking
There will no doubt be a use case for forking these templates in order to suit your own needs. If you fork this repo please ensure your retrospec config references your new repo url.

Please remember to update your retrospec config `plugins::puppet::templates::url: https://github.com/nwops/retrospec-templates.git`
So that it will always use your repository.  You can always pass in the template url to retrospec to override the default or config setting.

config file
```yaml
# where the clone hook will clone templates from
plugins::puppet::templates::url: 'git@github.com:nwops/retrospec-templates.git'
# where retrospec should look for templates
plugins::puppet::template_dir: '/Users/user1/retrospec-templates'
# branch of the retrospec templates
plugins::puppet::templates::ref: master
```

## Adding New Templates
Should you ever need to add new templates or non-template files of any kind retrospec will automatically render and copy the template file
to the module path if you place a file inside the `template_path/module_files` directory.  The cool thing about this feature
is that retrospec will recursively create the same directory structure you make inside the `module_files` directory inside your
module.  Files do not need to end in .erb and will still be rendered as a erb template.  Symlinks will be preserved and not dereferenced.

This follows the convention over configuration pattern so no directory name or filename is required when running retrospec.
Just put the template file in the directory where you want it (under module_files) and name it exactly how you want it to appear in the module and retrospec will take care of the rest.  Please note that any file ending in .erb will have this extension automatically removed.  You can optionally use .retrospec.erb to signify its a retrospec template.

Example:
So lets say you want to add a .gitlab-ci.yaml file to all of your modules in your modules directory.  

```shell
   touch ~/.retrospec_templates/module_files/.gitlab-ci.yaml

   tree ~/.retrospec_templates -a
   ./.retrospec_templates
   ├── acceptance_spec_test.erb
   ├── module_files
   │   ├── .fixtures.yml
   │   ├── .gitignore.erb
   │   ├── .gitlab-ci.yaml
   │   ├── .travis.yml
   │   ├── Gemfile
   │   ├── README.markdown
   │   ├── Rakefile
   │   ├── Vagrantfile
   │   └── spec
   │       ├── acceptance
   │       │   └── nodesets
   │       │       └── ubuntu-server-1404-x64.yml
   │       ├── shared_contexts.rb
   │       ├── spec_helper.rb
   │       └── spec_helper_acceptance.rb
   └── resource_spec_file.erb

# run retrospec for all modules in my puppet modules directory
    for dir in ../modules/*; do
       name=`basename $dir`
       retrospec -m $dir -e
       + /Users/user1/modules/module1/.gitlab-ci.yaml
    done

```

### Where to put template files
Template files that should only be rendered under special circumstances can be placed outside the module_files directory, otherwise they go in the module_files directory.

## Contributions
If you come up with some crafty code, find a fix, or just need to adjust a template and think that it will benefit everyone using these templates.  Please submit a PR. Keep in mind these templates are cloned every time someone uses retrospec.

It is easiest to test new templates if you clone this repo and then set your retrospec config setting to something like: `plugins::puppet::template_dir: '~/github/retrospec-templates'`
Then delete a file that you want retropec to create and re-run retrospec.

## TODO
* Make the clone-hook be more aware of branches, and allow it to switch branches after initially being cloned.  The idea here is that if we want to lock down this repo in the hook code it will only use that specific ref.
* Speed up the clone hook, git pull with every retrospec run is painful.
