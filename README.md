<p align="center">
  <img src="https://user-images.githubusercontent.com/4627720/297103738-dec9b331-7dea-4ab7-8e32-fe36a804788d.png?raw=true" alt="Trackmania image" height="100"/>

<p align="center">
    <a href="https://hub.docker.com/r/evoesports/trackmaniaforever">
        <img src="https://img.shields.io/docker/stars/evoesports/trackmaniaforever?&style=flat-square"
            alt="docker stars"></a>
    <a href="https://hub.docker.com/r/evoesports/trackmaniaforever">
        <img src="https://img.shields.io/docker/pulls/evoesports/trackmaniaforever?style=flat-square"
            alt="docker pulls"></a>
    <a href="https://hub.docker.com/r/evoesports/trackmaniaforever">
        <img src="https://img.shields.io/docker/v/evoesports/trackmaniaforever?style=flat-square"
            alt="docker image version"></a>
    <a href="https://hub.docker.com/r/evoesports/trackmaniaforever">
        <img src="https://img.shields.io/docker/image-size/evoesports/trackmaniaforever?style=flat-square"
            alt="docker image size"></a>
    <a href="https://discord.gg/evoesports">
        <img src="https://img.shields.io/discord/384138149686935562?color=%235865F2&label=discord&logo=discord&logoColor=%23ffffff&style=flat-square"
            alt="chat on Discord"></a>
</p>

## Table of Contents
- [Table of Contents](#table-of-contents)
- [How to use this image](#how-to-use-this-image)
  - [... with 'docker run'](#-with-docker-run)
  - [... with 'docker compose'](#-with-docker-compose)
- [Environment Variables](#environment-variables)
- [Features](#features)
  - [Prometheus Exporter](#prometheus-exporter)
- [Contributing](#contributing)


## How to use this image
### ... with 'docker run'
To start a TrackMania server with `docker run`:
```shell
docker run \
  -e TMF_MASTERSERVER_LOGIN='YourMasterserverLogin' \
  -e TMF_MASTERSERVER_PASSWORD='YourMasterserverPassword' \
  -p 2350:2350/tcp \
  -p 2350:2350/udp \
  -p 3450:3450/tcp \
  -p 3450:3450/udp \
  #-p 5000:5000/tcp \ # Be careful opening XMLRPC! Only if you know what you're doing.
  #-p 9000:9000/tcp \ # For the prometheus exporter. Usually not needed, unless Prometheus is running on a different host.
  -v GameData:/server/GameData \
  evoesports/trackmaniaforever:latest
```

### ... with 'docker compose'
To do the same with `docker compose`:
```yaml
version: "3.8"
services:
  trackmania:
    image: evoesports/trackmaniaforever:latest
    ports:
      - 2350:2350/udp
      - 2350:2350/tcp
      - 3450:3450/udp
      - 3450:3450/tcp
      #- 5000:5000/tcp # Be careful opening XMLRPC! Only if you know what you're doing.
      #- 9000:9000/tcp # For the prometheus exporter. Usually not needed, unless Prometheus is running on a different host.
    environment:
      TMF_MASTERSERVER_LOGIN: "YourMasterserverLogin"
      TMF_MASTERSERVER_PASSWORD: "YourMasterserverPassword"
    volumes:
      - GameData:/server/GameData
volumes:
  GameData:
```
In both cases, the server will launch and be bound to port 2350 & 3450, TCP + UDP. Port 5000 (XMLRPC) & 9000 (Prometheus metrics) won't usually be forwarded to the host, because apps who need it (e.g. server controllers) are supposed to run in the same stack.
You need to provide server credentials that you can register [here](https://players.trackmaniaforever.com/main.php?view=dedicated-servers), and put the login into the `TMF_MASTERSERVER_LOGIN` variable, and the password into the `TMF_MASTERSERVER_PASSWORD` variable.
The server only needs one volume to store your game data (e.g. maps, configs), which is mounted to /server/GameData. You can also use bind mounts.

## Environment Variables
| **Environment Variable**                  | **Description**                                                                                                               | **Default Value**[^1]             | **Required** |
|-------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------|-----------------------------------|:------------:|
| `TMF_AUTHORIZATION_SUPERADMIN_PASSWORD`    | Password for the SuperAdmin level.                                                                                            | SuperAdmin                        |              |
| `TMF_AUTHORIZATION_ADMIN_PASSWORD`         | Password for the Admin level.                                                                                                 | Admin                             |              |
| `TMF_AUTHORIZATION_USER_PASSWORD`          | Password for the User level.                                                                                                  | User                              |              |
| `TMF_MASTERSERVER_LOGIN`                   | Your server login name. (e.g. 'yourcoolserverlogin')                                                                          |                                   |       ✔      |
| `TMF_MASTERSERVER_PASSWORD`                | Your server login password you got from the Trackmania player page.                                                           |                                   |       ✔      |
| `TMF_MASTERSERVER_VALIDATION_KEY`          | Your validation key. Needed for copper transactions.                                                                          |                                   |              |
| `TMF_SERVER_NAME`                          | The server name. (Only used once if there's no server name already set in the server config file.)                            | Docker TrackManiaForever Server   |              |
| `TMF_SERVER_NAME_OVERWRITE`                | If set to True, the docker image will overwrite the server name in the config everytime the server starts.                    | False                             |              |
| `TMF_SERVER_COMMENT`                       | A comment about the server.                                                                                                   |                                   |              |
| `TMF_SERVER_HIDE_SERVER`                   | Whether the server is hidden. 0 (always shown), 1 (always hidden), 2 (hidden from nations)                                    | 0                                 |              |
| `TMF_SERVER_MAX_PLAYERS`                   | Max amount of players the server can have.                                                                                    | 32                                |              |
| `TMF_SERVER_PASSWORD`                      | The password the players have to enter upon joining the server.                                                               |                                   |              |
| `TMF_SERVER_MAX_SPECTATORS`                | Max amount of spectators a server can have.                                                                                   | 32                                |              |
| `TMF_SERVER_PASSWORD_SPECTATOR`            | The password the spectators have to enther upon joining the server.                                                           |                                   |              |
| `TMF_SERVER_LADDER_MODE`                   | Enables or disables the ladder mode. forced for enabled, inactive for disabled.                                               | forced                            |              |
| `TMF_SERVER_LADDER_SERVERLIMIT_MIN`        | Minimum ladder limit. Usually you don't need to set this.                                                                     | 0                                 |              |
| `TMF_SERVER_LADDER_SERVERLIMIT_MAX`        | Maximum ladder limit. Usually you don't need to set this.                                                                     | 50000                             |              |
| `TMF_SERVER_ENABLE_P2P_UPLOAD`             | Whether P2P Upload is enabled.                                                                                                | True                              |              |
| `TMF_SERVER_ENABLE_P2P_DOWNLOAD`           | Whether P2P Download is enabled.                                                                                              | True                              |              |
| `TMF_SERVER_CALLVOTE_TIMEOUT`              | How long a vote is going on.                                                                                                  | 60000                             |              |
| `TMF_SERVER_CALLVOTE_RATIO`                | How many people it needs to pass a vote. 0.5 means at least half of them is needed.                                           | 0.5                               |              |
| `TMF_SERVER_ALLOW_CHALLENGE_DOWNLOAD`      | If it's allowed for players to download the server maps.                                                                      | True                              |              |
| `TMF_SERVER_AUTOSAVE_REPLAYS`              | If the server saves replays automatically.                                                                                    | False                             |              |
| `TMF_SERVER_AUTOSAVE_VALIDATION_REPLAYS`   | If the server saves validation replays automatically.                                                                         | False                             |              |
| `TMF_SERVER_REFEREE_PASSWORD`              | The password for the referee mode.                                                                                            |                                   |              |
| `TMF_SERVER_REFEREE_VALIDATION_MODE`       | 0 (only validate top3 players),  1 (validate all players)                                                                     | 0                                 |              |
| `TMF_SERVER_USE_CHANGING_VALIDATION_SEED`  | It micro-shifts your car at the start line. It should prevent replay input cheats. Breaks PF tracks.                          |                                   |              |
| `TMF_SYSTEM_CONNECTION_UPLOADRATE`         | The maximal upload speed the server is able to use. In kbps.                                                                  | 512                               |              |
| `TMF_SYSTEM_CONNECTION_DOWNLOADRATE`       | The maximal download speed the server is able to use. In kbps.                                                                | 8192                              |              |
| `TMF_SYSTEM_FORCE_IP_ADDRESS`              | Usually the public IP of the server including the port. (e.g. 127.0.0.1:2350)[^2]                                             |                                   |              |
| `TMF_SYSTEM_BIND_IP_ADDRESS`               | If the machine has multiple network interfaces, you can set here the IP the server listens on.                                |                                   |              |
| `TMF_SYSTEM_USE_NAT_UPNP`                  | If the server should try to forward ports automatically.                                                                      |                                   |              |
| `TMF_SYSTEM_P2P_CACHE_SIZE`                | The size of the P2P cache.                                                                                                    | 600                               |              |
| `TMF_SYSTEM_XMLRPC_ALLOWREMOTE`            | Controls if the server allows external connections to XMLRPC.                                                                 | False[^3]                         |              |
| `TMF_SYSTEM_BLACKLIST_URL`                 | URL to a blacklist file hosted on a webserver.                                                                                |                                   |              |
| `TMF_SYSTEM_GUESTLIST_FILENAME`            | Filename of a guestlist file.                                                                                                 |                                   |              |
| `TMF_SYSTEM_BLACKLIST_FILENAME`            | Filename of a blacklist file.                                                                                                 |                                   |              |
| `TMF_SYSTEM_PACKMASK`                      | For a nation server, set it to stadium. For a United server, set it to united.                                                | stadium                           |              |
| `TMF_SYSTEM_ALLOW_SPECTATOR_RELAYS`        | If relays are able to connect to the server.                                                                                  | False                             |              |
| `TMF_SYSTEM_SAVE_ALL_INDIVIDUAL_RUNS`      | If the server should save all individual runs.                                                                                | False                             |              |
| `TMF_SYSTEM_USE_PROXY`                     | If the server needs to use a proxy.                                                                                           | False                             |              |
| `TMF_SYSTEM_PROXY_LOGIN`                   | Username of the proxy .                                                                                                       |                                   |              |
| `TMF_SYSTEM_PROXY_PASSWORD`                | Password of the proxy.                                                                                                        |                                   |              |
| `TMF_DEDICATED_CFG`                        | In case you created your own server config and want to use that one instead.                                                  | dedicated_cfg.txt                 |              |
| `TMF_GAME_SETTINGS`                        | In case you created your own matchsettings and want to use that one instead.                                                  | default.txt                       |              |
| `PROMETHEUS_ENABLE`                       | Enable the Prometheus Trackmania exporter.                                                                                    | False                             |              |
| `PROMETHEUS_PORT`                         | The port the Prometheus Trackmania exporter will listen on.                                                                   | 9000                              |              |
| `PROMETHEUS_SUPERADMIN_PASSWORD`          | The SuperAdmin password the Prometheus exporter needs in case it got changed.                                                 | SuperAdmin                        |              |
| `PROMETHEUS_INTERVAL`                     | The interval the prometheus exporter gets the metrics from the TrackMania server.                                             | 15                                |              |
| `CONFIG_POPULATION_DISABLED`              |                                                                                                                               |                                   |              |
[^1]: Default value of this docker image. Does not represent the defaults by the TrackMania server provided by Ubisoft Nadeo.
[^2]: If left unset, the TrackMania server will report the Docker internal IP address to the masterserver, which will prevent people from connecting to it.
[^3]: `True` here doesn't mean anyone can connect to the XMLRPC interface. It just allows connections from other containers to be made to it, for example from server controllers like XAseco or Minicontrol.


## Features
### Prometheus Exporter
The image contains a small (~6MB) prometheus exporter. It can be enabled through the `PROMETHEUS_ENABLE` variable. The container will then expose metrics about the TrackMania server on port 9000.

Example output:
```
# HELP trackmania_player_count Current player count by type.
# TYPE trackmania_player_count gauge
trackmania_player_count{type="online"} 8.0
trackmania_player_count{type="spectating"} 0.0
trackmania_player_count{type="driving"} 8.0
# HELP trackmania_moderation_count Current players count being moderated by type.
# TYPE trackmania_moderation_count gauge
trackmania_moderation_count{type="banned"} 1.0
trackmania_moderation_count{type="blacklisted"} 1.0
trackmania_moderation_count{type="guestlisted"} 0.0
trackmania_moderation_count{type="ignored"} 0.0
# HELP trackmania_player_count_mean The mean value of the player count.
# TYPE trackmania_player_count_mean gauge
trackmania_player_count_mean 6.0
# HELP trackmania_server_uptime Time since the TrackMania server has started in seconds.
# TYPE trackmania_server_uptime gauge
trackmania_server_uptime 459307.0
# HELP trackmania_connection_count Total connections made to the TrackMania server.
# TYPE trackmania_connection_count gauge
trackmania_connection_count 1397.0
# HELP trackmania_connection_time_mean The mean value of the connection time in ms.
# TYPE trackmania_connection_time_mean gauge
trackmania_connection_time_mean 2041.0
# HELP trackmania_net_rate_recv Connection rate inbound in kbps.
# TYPE trackmania_net_rate_recv gauge
trackmania_net_rate_recv 137.0
# HELP trackmania_net_rate_send Connection rate outbound in kbps.
# TYPE trackmania_net_rate_send gauge
trackmania_net_rate_send 76.0
# HELP trackmania_maps_count Amount of maps the server currently has loaded.
# TYPE trackmania_maps_count gauge
trackmania_maps_count 99.0
# HELP trackmania_player_max Max configured amount of players the server can hold.
# TYPE trackmania_player_max gauge
trackmania_player_max{type="players"} 150.0
trackmania_player_max{type="spectators"} 32.0
```
## Contributing
If you have any questions, issues, bugs or suggestions, don't hesitate and open an [Issue](https://github.com/evoesports/docker-trackmaniaforever/issues/new)! You can also join our [Discord](https://discord.gg/evoesports) for questions.

You may also help with development by creating a pull request.
