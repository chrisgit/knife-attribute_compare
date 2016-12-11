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
* Sort attributes and open diff tool for comparison (TODO)
* Basic report of differences between environment files

Parameters are
| parameter        | short | description                                                  |
| --report         |       | Show basic report                                            |


#### Ruby versions

Works with Ruby versions
* 1.9.3 
* 2.3.1p112 (2016-04-26 revision 54768) [i386-mingw32]
