# hauntourage
What do you call a group of ghosts? A Hauntourage! 👻🤣
Custom script for deploying multiple GhostCMS instances on one server.

## Backstory
I want to deploy multiple sites to one server using a docker container for each site, using nginx for routing traffic to the individual sites

## Tech Stack
* Vagrant
* Virtualbox
* Docker
* Nginx (reverse proxy)
* Ghost CMS (content server)
* AWS CLI tools (awscli)

## Usage

On vagrant, for local development just run ```vagrant up```

Make sure to update ```/etc/hosts``` with any domains that are listed in ```sites/active```

You will probably need to change the local IP address to match your subnet
