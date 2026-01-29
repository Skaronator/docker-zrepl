FROM debian:13.1-slim

RUN set -euxo pipefail && \
    DEBIAN_FRONTEND=noninteractive && \
    # Add APT repositories
    apt-get update && apt-get install --yes --no-install-recommends ca-certificates curl gnupg lsb-release && \
    # Add zrepl repo key (avoid apt-key, use signed-by instead)
    install -d -m 0755 /usr/share/keyrings && \
    curl -fsSL --insecure https://zrepl.cschwarz.com/apt/apt-key.asc \
      | gpg --dearmor -o /usr/share/keyrings/zrepl-archive-keyring.gpg && \
    # Setup zrepl package
    . /etc/os-release && \
    ARCH="$(dpkg --print-architecture)" && \
    echo "deb [arch=$ARCH signed-by=/usr/share/keyrings/zrepl-archive-keyring.gpg] https://zrepl.cschwarz.com/apt/$ID $VERSION_CODENAME main" > /etc/apt/sources.list.d/zrepl.list && \
    echo "deb http://deb.debian.org/$ID stable contrib" > /etc/apt/sources.list.d/stable-contrib.list && \
    # Add Backports
    echo "deb http://deb.debian.org/debian $VERSION_CODENAME-backports main contrib non-free-firmware" >> /etc/apt/sources.list.d/backports.list && \
    echo "deb-src http://deb.debian.org/debian $VERSION_CODENAME-backports main contrib non-free-firmware" >> /etc/apt/sources.list.d/backports.list && \
    # Pin ZFS Backports
    echo "Package: src:zfs-linux" >> /etc/apt/preferences.d/90_zfs && \
    echo "Pin: release n=$VERSION_CODENAME-backports" >> /etc/apt/preferences.d/90_zfs && \
    echo "Pin-Priority: 990" >> /etc/apt/preferences.d/90_zfs && \
    apt-get update && \
    # Install zrepl and its user-land ZFS utils dependency
    apt-get install --yes --no-install-recommends zrepl zfsutils-linux && \
    # zrepl expects /var/run/zrepl
    mkdir -p /var/run/zrepl && chmod 0700 /var/run/zrepl && \
    # Reduce final Docker image size: Clear the APT cache
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    # check versions
    zrepl version --show client && \
    zfs --version 2>/dev/null || true &&\
    # verify zfs is installed
    zfs --help && \
    zpool --help

CMD ["daemon"]
ENTRYPOINT ["/usr/bin/zrepl", "--config", "/etc/zrepl/zrepl.yml"]

WORKDIR /etc/zrepl
