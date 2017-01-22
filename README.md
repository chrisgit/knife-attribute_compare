Knife Attribute
===============

Knife plugin to 
* Compare attributes from one environment to another

## Requirements

You will need 
* Ruby installed or Chef or ChefDK

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
* Basic report of differences between environment files

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
knife attribute compare <environment1> <environment2>
````

- Using Diff Tool NOT configured in knife.rb
````
knife attribute compare <environment1> <environment2> --diff_tool="C:/Program Files (x86)/WinMerge/WinMergeU.exe"
````

- Using report
````
knife attribute compare <environment> <environment> --report
````

#### Future
- Change set_paths to generate methods?
- Node comparison

#### Ruby versions

Works with Ruby versions
* 1.9.3 
* 2.3.1p112 (2016-04-26 revision 54768) [i386-mingw32]
