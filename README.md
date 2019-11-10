# Website

[![Build Status](https://travis-ci.com/leonyork/website.svg?branch=master)](https://travis-ci.com/leonyork/website)

Goto [leonyork.com](https://leonyork.com) to view.

Everything is run in docker (using make to shorten commands). This means that development should work the same across OS's and versions of node, nginx, etc. are defined within the project

You'll need make, docker and docker-compose installed to run this project.

Look in the [Makefile](./Makefile) to see what commands you can use. You can run ```make [command]``` (e.g. ```make .dev```).

Also has support for using VS code to [develop inside the development container](https://code.visualstudio.com/docs/remote/containers).