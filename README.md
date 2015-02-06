#local

This repo holds some simple scripts to help bootstrap a development environment. It attempts to present an idempotent interface to help manage global dependencies. In general, I'm of the opinion that global dependencies should be avoided, but sometimes they are necessary, so I made this repo. Use it or don't.

##installation

Since this is meant to run in an environment without any dependencies installed, it's just written in bash. To use it, just source `local.bash` from your bootstrap script, and then call any of the below functions.

##homebrew functions

###`brew_setup`
A function of no arguments that installs homebrew and its dependencies (notably, the xcode developers tools).

###`brew_tap <keg>`
Tap a keg, unless it is already tapped.

###`brew_install <package> <options...>`
Install a package, unless it is already installed. Optionally, you can specify a specific version:
    
    brew_install "elasticsearch==1.3.4"
    
Or pass some installation options that get forwarded to `brew install`:

    brew_install "nginx-full" --with-lua-module

###`brew_start <service>`
Start a service installed by brew, unless it is already started.

###`brew_enable <service>`
Enable a service (which means, make sure it runs on startup), unless it is already enabled.

##cask functions

###`cask_setup`
Install cask (via `brew`) unless it is already installed.

###`cask_install <package>`
Install a package with cask, unless it is already installed.


##pip functions

###`pip_setup`
Install pip globally, unless it is already installed.

###`pip_install <package>`
Install a (global) pip package, unless it is already installed.

