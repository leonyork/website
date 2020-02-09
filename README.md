# Website

[![Build Status](https://travis-ci.com/leonyork/website.svg?branch=master)](https://travis-ci.com/leonyork/website)

Goto [leonyork.com](https://leonyork.com) to view.

Everything is run in docker (using make to shorten commands). This means that development should work the same across OS's and versions of node, nginx, etc. are defined within the project

## Prerequisites

You'll need [make](https://www.gnu.org/software/make/), [docker-compose](https://docs.docker.com/compose/install/) and [docker](https://docs.docker.com/install/) installed to run this project.

To deploy you'll need to make sure you have the following environment variables set:

- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY

See [the AWS documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html).

## Tasks

Look in the [Makefile](./Makefile) to see what commands you can use. You can run ```make [command]``` (e.g. ```make dev```).

For the different stages of the build see [the travis file](./.travis.yml)

### Developing e2e tests

Alongside make, docker and docker-compose you'll need nodejs installed (so you can access the cypress gui).

Run ```make dev``` so you've got a development environment running.

Run ```make e2e-dev``` to run the cypress gui.