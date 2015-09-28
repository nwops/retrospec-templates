# Retrospec Templates
These templates have been migrated from the retrospec tool.  The retrospec tool used to contain these templates 
inside the gem but have been pulled out in order to make template changes more streamlined. Additionally, it is quite
common to have multiple sets of templates when working with various clients so having a beginning repo helps out.

## Usage
These templates are for use with the Retrospec tool (https://github.com/nwops/puppet-retrospec)
You can clone these templates yourself, but Retrospec by default will clone this repo automatically.

Should want to use your own fork of these templates with retrospec you can specifiy the scm url to point to whatever.
I have specifically designed retrospec to not depend on any one single SCM.  However, the hooks contained in this
repo only work with git.

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
## Hooks
Hooks were a feature added in the 0.8.0 release of retrospec and are used to perform additional puppet
module development automation. These hooks come pre-populated with some basic magic, but are intended to be changed
to suit your development workflows.  Make sure your hooks have the executable bit set or retrospec cannot execute them.

By default these hooks were programmed using Ruby and Bash but you are free to use any language as long as your script
is executable. (Python, Ruby, Bash, Zsh, Go, Rust, ...).

### Clone-hook
This hook is called at the initialization time when running Retrospec.  Its primary use is to seed the templates that 
are used to retrofit your module.  By default the hook will clone from https://github.com/nwops/retrospec-templates.git.
However, this behavior can be changed by using the `-s` switch from retrospec or by changing the default url in the hook
code.

### Pre-hook
This hook is called after the clone hook and before retrospec creates the files in your module.  Its useful for performing
additional development workflows like setting up git hooks inside a persons module directory.  Because some tasks
cannot be saved in this repository you can utilize the pre-hook to set up these items each time retrospec is called.  By default
this hook will clone the [repo](https://github.com/drwahl/puppet-git-hooks) inside ~/.retrospec/repos and create a symlink
to the pre-commit hook to the templates modules_files/.git/hooks/pre-commit.  What this does is ensure all your puppet
modules automatically test code before committing based on the pre-commit hook code. This alone will hopefully save you 
10 minutes for each use.

### Post-hook
This hook is called after creating the files in your module.  It can also be use to setup scm hooks.  If you find a
good use case with the post-hook let me know as its just another hook to be called.  Maybe you can use this hook to
set a running tabulation of how much time you saved using retrospec.

## Forking
There will no doubt be a use case for forking these templates in order to suit your own needs.  If this is the case
you will want to change the `@template_repo   = ARGV[1] || 'https://github.com/nwops/retrospec-templates' `
in the clone-hook to use your own url by default or always remember to pass it on from the command line.

### Contributions
If you come up with some crafty code, find a fix, or just need to adjust a template and think that it will benefit 
everyone using these templates.  Please submit a PR against the `develop` branch. Keep in mind these templates are cloned 
everytime someone uses retrospec. 


## TODO
Make the clone-hook be more aware of branches, and allow it to switch branches after initially being cloned.  The idea
here is that if we want to lock down this repo in the hook code it will only use that specific ref.