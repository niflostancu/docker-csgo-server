# Dockerized Counter-Strike: Global Offensive (CSGO) dedicated server

This are my scripts for hosting a CSGO dedicated server with serveral goodies
included:

- integrated SourceMod plugins and configuration management scripts;
- sidecar nginx-based web server for FastDL (for fast resource downloading -
  obligatory sometimes for custom maps);
- custom configs for several game modes (everything is fully overridable);
- some custom sourcemod plugins;
- out of tree deployment method for customizability / secrets management best
  practice.

## Getting started

First, clone this repository somewhere on your filesystem:
```sh
git clone https://github.com/niflostancu/docker-csgo-server
```

After that, enter the project's directory and build the Docker image:
```sh
# hint: you can create a local.mk file with Make variables you want to override!
make build
```

Now copy the sample deployment files and start customizing your server!

Note: do not modify the in-tree `deploy.example` directory! Instead, you should
either copy it as `<name>.local` (all files ending in `.local` are gitignored)
or move it to a separate directory altogether (hint: somewhere you have >= 32GB
of free space!)

```sh
cp -ar deploy.example deploy.local
cd deploy.local
# start modifying the configuration files
```

The minimal set of files you need for a succesful instance:
- [`docker-compose.example.yml`](./deploy.example/docker-compose.example.yml):
  rename to `docker-compose.yml` and update the
  `game` volume to somewhere you have free disk space for the game to be
  downloaded (make sure to read the [Docker
  Compose](https://docs.docker.com/compose/compose-file/#volumes) documentation)
- [`secrets.env.example`](./deploy.example/secrets.env.example): rename to
  `secrets.env` and replace the tokens (read the [official CSGO DS
  documentation](https://developer.valvesoftware.com/wiki/Counter-Strike:_Global_Offensive_Dedicated_Servers)
  for the required tokens)

Everything else can be customized either by docker volume mounts, rebasing the
container image or using the [`csgo-override`](./deploy.example/csgo-override/)
directory (while keeping the same hierarchy as [`csgo`](./csgo/) from the
source code).

