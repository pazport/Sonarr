# <img width="24px" src="./Logo/256.png" alt="Sonarr"></img> Sonarr

[![Translated](https://translate.servarr.com/widget/servarr/sonarr/svg-badge.svg)](https://translate.servarr.com/engage/servarr/)
[![Backers on Open Collective](https://opencollective.com/Sonarr/backers/badge.svg)](#backers)
[![Sponsors on Open Collective](https://opencollective.com/Sonarr/sponsors/badge.svg)](#sponsors)
[![Mega Sponsors on Open Collective](https://opencollective.com/Sonarr/megasponsors/badge.svg)](#mega-sponsors)

Sonarr is a PVR for Usenet and BitTorrent users. It can monitor multiple RSS feeds for new episodes of your favorite shows and will grab, sort and rename them. It can also be configured to automatically upgrade the quality of files already downloaded when a better quality format becomes available.

## Getting Started

- [Download/Installation](https://sonarr.tv/#downloads-v3)
- [FAQ](https://wiki.servarr.com/sonarr/faq)
- [Wiki](https://wiki.servarr.com/Sonarr)
- [API Documentation](https://sonarr.tv/docs/api)
- [Donate](https://sonarr.tv/donate)

## Support

Note: GitHub Issues are for Bugs and Feature Requests Only

- [Forums](https://forums.sonarr.tv/)
- [Discord](https://discord.gg/M6BvZn5)
- [GitHub - Bugs and Feature Requests Only](https://github.com/Sonarr/Sonarr/issues)
- [IRC](https://web.libera.chat/?channels=#sonarr)
- [Reddit](https://www.reddit.com/r/sonarr)
- [Wiki](https://wiki.servarr.com/sonarr)

## Features

### Current Features

- Support for major platforms: Windows, Linux, macOS, Raspberry Pi, etc.
- Automatically detects new episodes
- Can scan your existing library and download any missing episodes
- Can watch for better quality of the episodes you already have and do an automatic upgrade. _eg. from DVD to Blu-Ray_
- Automatic failed download handling will try another release if one fails
- Manual search so you can pick any release or to see why a release was not downloaded automatically
- Fully configurable episode renaming
- Full integration with SABnzbd and NZBGet
- Full integration with Kodi, Plex (notification, library update, metadata)
- Full support for specials and multi-episode releases
- And a beautiful UI

## Building with Docker

The `Dockerfile` builds the frontend and backend from source and produces an image that runs Sonarr:

```
docker build -t sonarr .
docker run -d --name sonarr --restart unless-stopped -p 8989:8989 -v /path/to/config:/config -v /path/to/tv:/tv -v /path/to/downloads:/downloads sonarr
```

Sonarr runs as a non-root user (UID 1654), so the mounted folders must be writable by that user, e.g. `sudo chown -R 1654:1654 /path/to/config`.

## Stuck Task Watchdog

`scripts/sonarr-pmd-watchdog.sh` restarts Sonarr when the Process Monitored Downloads task has been running for longer than `MAX_MINUTES`, then queues the task again. It requires `curl` and `jq`.

| Variable | Default | Description |
| --- | --- | --- |
| `SONARR_URL` | `http://localhost:8989` | Sonarr base URL |
| `SONARR_API_KEY` | _(required)_ | API key from Settings > General |
| `MAX_MINUTES` | `5` | Minutes the task can run before Sonarr is restarted |
| `WAIT_SECONDS` | `10` | Seconds between checks while waiting for Sonarr to restart |

Run it from cron every minute:

```
* * * * * SONARR_URL=http://localhost:8989 SONARR_API_KEY=yourkey MAX_MINUTES=10 /path/to/scripts/sonarr-pmd-watchdog.sh >> /var/log/sonarr-watchdog.log 2>&1
```

## Contributing

### Development

This project exists thanks to all the people who contribute. [Contribute](CONTRIBUTING.md).

<a href="https://github.com/Sonarr/Sonarr/graphs/contributors"><img src="https://opencollective.com/Sonarr/contributors.svg?width=890&button=false" /></a>

### Supporters

This project would not be possible without the support of our users and software providers.
[**Become a sponsor or backer**](https://opencollective.com/sonarr) to help us out!

#### Mega Sponsors

[![Sponsors](https://opencollective.com/sonarr/tiers/mega-sponsor.svg?width=890)](https://opencollective.com/sonarr/contribute/mega-sponsor-21443/checkout)

#### Sponsors

[![Flexible Sponsors](https://opencollective.com/sonarr/sponsors.svg?width=890)](https://opencollective.com/sonarr/contribute/sponsor-21457/checkout)

#### Backers

[![Backers](https://opencollective.com/sonarr/backers.svg?width=890)](https://opencollective.com/sonarr/contribute/backer-21442/checkout)

#### JetBrains

Thank you to [<img src="https://resources.jetbrains.com/storage/products/company/brand/logos/jetbrains.png" alt="JetBrains" width="96">](http://www.jetbrains.com/) for providing us with free licenses to their great tools

[<img src="https://resources.jetbrains.com/storage/products/company/brand/logos/TeamCity.png" alt="TeamCity" width="64">](http://www.jetbrains.com/teamcity/)

[<img src="https://resources.jetbrains.com/storage/products/company/brand/logos/ReSharper.png" alt="ReSharper" width="64">](http://www.jetbrains.com/resharper/)

[<img src="https://resources.jetbrains.com/storage/products/company/brand/logos/dotTrace.png" alt="dotTrace" width="64">](http://www.jetbrains.com/dottrace/)

[<img src="https://resources.jetbrains.com/storage/products/company/brand/logos/Rider.png" alt="Rider" width="64">](http://www.jetbrains.com/rider/)

### Licenses

- [GNU GPL v3](http://www.gnu.org/licenses/gpl.html)
- Copyright 2010-2025
