# zrepl Docker Container Image

One-stop ZFS backup & replication solution

[https://github.com/zrepl/zrepl](https://github.com/zrepl/zrepl)

## Usage

The usage of this container image is pretty straightforward. It's basically just zrepl as a container image.

You need to mount your zrepl config at `/etc/zrepl/zrepl.yml`.

```bash
docker run -v $PWD/zrepl.yml:/etc/zrepl/zrepl.yml:ro ghcr.io/skaronator/zrepl-dl -d --privileged
```

Information about the zrepl.yml config file can be found in the offical documentation: [https://zrepl.github.io/configuration.html](https://zrepl.github.io/configuration.html)
