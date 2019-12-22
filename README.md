# Website

[![Build Status](https://travis-ci.com/leonyork/website.svg?branch=master)](https://travis-ci.com/leonyork/website)

Goto [leonyork.com](https://leonyork.com) to view.

Everything is run in docker (using make to shorten commands). This means that development should work the same across OS's and versions of node, nginx, etc. are defined within the project

You'll need make, docker and docker-compose installed to run this project.

Look in the [Makefile](./Makefile) to see what commands you can use. You can run ```make [command]``` (e.g. ```make .dev```).

Also has support for using VS code to [develop inside the development container](https://code.visualstudio.com/docs/remote/containers).

To deploy you'll need to make sure you have the following environment variables set:

AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY

## Developing e2e tests

Alongside make, docker and docker-compose you'll need nodejs installed (so you can access the cypress gui)

Run ```make .dev``` so you've got a development environment running

Run the following to start the cypress gui:
 1) ```cd e2e```
 1) ```npm install```
 1) ```npm test```