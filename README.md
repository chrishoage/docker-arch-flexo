# docker-arch-flexo
Arch Linux base image for Flexo with automatic cache clean

## Usage


See [Flexo configuration](https://github.com/nroi/flexo/blob/master/flexo/conf/flexo.toml) for all `FLEX_` prefixed environment variables

- `FLEXO_CACHE_DIRECTORY`
- `FLEXO_LOW_SPEED_LIMIT`
- `FLEXO_LOW_SPEED_TIME_SECS`
- `FLEXO_MIRRORLIST_FALLBACK_FILE`
- `FLEXO_PORT`
- `FLEXO_MIRROR_SELECTION_METHOD`
- `FLEXO_MIRRORS_PREDEFINED`
- `FLEXO_MIRRORS_BLACKLIST`
- `FLEXO_MIRRORS_AUTO_HTTPS_REQUIRED`
- `FLEXO_MIRRORS_AUTO_IPV4`
- `FLEXO_MIRRORS_AUTO_IPV6`
- `FLEXO_MIRRORS_AUTO_MAX_SCORE`
- `FLEXO_MIRRORS_AUTO_NUM_MIRRORS`
- `FLEXO_MIRRORS_AUTO_MIRRORS_RANDOM_OR_SORT`
- `FLEXO_MIRRORS_AUTO_TIMEOUT`

Container Specific environment variables

- `CRON_PACCACHE_CLEAN`: Cron tab for how frequently to clean flexo cache. Defaults to Every week on Monday at at 12:08 AM container time
- `CRON_PACCACHE_KEEP`: How many packages to keep in each repo cache. Defaults to 3

## Volumes

- `/var/cache/flexo` is an exposed volume and must be mounted to preserve cache
- `/etc/flexo` is optional, and is where flexo.toml would live. Flexo may be configured though the provided environment variables


### Example docker-compose

```yml
version: 3.1
services:
  flexo:
    image: ghcr.io/chrishoage/arch-flexo:latest
    volumes:
      - flexo_cache:/var/cache/flexo
    envrionment:
      - CRON_PACCACHE_KEEP=2

volumes:
  flexo_cache:
```
