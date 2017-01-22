Knife Attribute
===============

Knife plugin to compare attributes for
* Chef Environments
* Chef Nodes

The out of the box knife environment compare plugin works well for Cookbook version constraints

## Requirements

You will need 
* Ruby installed and Chef 

or preferably 

* ChefDK

#### Building

Build the gem with 
````
gem build knife_attribute.gemspec
````
http://guides.rubygems.org/make-your-own-gem/

## Installation

````
gem install knife_attribute
````

or 

````
gem install --local <path to gem>/knife_attribute.gem
````

## Usage

The knife_attribute gem has the following functions
* Sort attributes and open diff tool for comparison
* Basic report of differences between Chef Objects (node or environment)

Parameters are:

| parameter        | short | description                                                  |
|------------------|-------|--------------------------------------------------------------|
| --report         |       | Show basic report                                            |
| --diff_tool      |       | Convert to dot notation and call diff tool                   |

--report is the default behavior unless --diff_tool is specified.

If diff_tool is always required then it is easier to add a section into knife.rb
e.g. Add the following to knife.rb (if you use WinMerge), note for Windows you need to quote paths if they include spaces
````
knife[:diff_tool] = '"C:/Program Files (x86)/WinMerge/WinMergeU.exe"'
````

Example calls
- Using Diff Tool configured in knife.rb
````
knife attribute compare environment <environment1> <environment2>
````

- Using Diff Tool NOT configured in knife.rb
````
knife attribute compare environment <environment1> <environment2> --diff_tool="C:/Program Files (x86)/WinMerge/WinMergeU.exe"
````

- Using report
````
knife attribute compare environment <environment> <environment> --report
````

#### Future
- Change set_paths to generate methods?
- Embed loading mechanism in AttributeObject (or make simpler)
- Reduce code, take common code paths and wrap into methods / classes

#### Ruby versions

Works with Ruby versions
* 1.9.3 
* 2.3.1p112 (2016-04-26 revision 54768) [i386-mingw32]
