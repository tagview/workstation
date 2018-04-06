# Workstation

Workstation is a serie of scripts and configurations to set up a web development environment.

All the scripts are idempotent, which means it can be run multiple times safely.

## OSX

The OSX configuration uses Homebrew to install a series of databases and libraries.

To run the script, just paste the following line on your terminal:

```
curl -fsSL https://raw.githubusercontent.com/tagview/workstation/master/osx.sh | sh
```

Note that the script will ask for your `sudo` credentials multiple times.

### Configuration

Some optioned configurations will also be enabled:

- Fast keyboard repeat rate
- Enable element inspection on NSWebView
- Use tabs to navigate through prompts
- Always show file extensions
- Don't always ask for using connected external drive with Timemachine
- Turn off keyboard illumination when it is not touched for five minutes

## Ubuntu

```
curl -fsSL https://raw.githubusercontent.com/tagview/workstation/master/ubuntu.sh | sh
```

Note that the script will ask for your `sudo` credentials multiple times.

## Applications installed

- Git: the latest version
- Postgres
- MySQL
- Redis
- Memcache
- Vim
- Imagemagick
- Ruby
- NodeJS
- Watch
- Tree
- Arcanist: to interact with Phabricator
- Heroku Toolbelt

## Contributing
### Ubuntu
Test the ubuntu setup with docker:
```
$ docker build -t ubuntu-workstation .
$ docker run -ti ubuntu-workstation /bin/sh /home/docker/ubuntu.sh
# the test user's password is "docker"
```
