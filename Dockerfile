FROM debian:12.1

RUN set -eux && \
    DEBIAN_FRONTEND=noninteractive \
    # Add APT repositories
    apt-get update && apt-get install --yes --no-install-recommends ca-certificates curl gnupg lsb-release && \
    (curl -fsSL --insecure https://zrepl.cschwarz.com/apt/apt-key.asc | apt-key add -) && \
    ( \
      . /etc/os-release && \
      ARCH="$(dpkg --print-architecture)" && \
      # TODO: Replace "bullseye" with $VERSION_CODENAME
      # once https://github.com/zrepl/zrepl/issues/721 was fixed
      echo "deb [arch=$ARCH] https://zrepl.cschwarz.com/apt/$ID bullseye main" > /etc/apt/sources.list.d/zrepl.list && \
      echo "deb http://deb.debian.org/$ID stable contrib" > /etc/apt/sources.list.d/stable-contrib.list && \
      # Add Backports
      echo "deb http://deb.debian.org/debian $VERSION_CODENAME-backports main contrib" >> /etc/apt/sources.list.d/backports.list && \
      echo "deb-src http://deb.debian.org/debian $VERSION_CODENAME-backports main contrib" >> /etc/apt/sources.list.d/backports.list && \
      # Pin ZFS Backports
      echo "Package: src:zfs-linux" >> /etc/apt/preferences.d/90_zfs && \
      echo "Pin: release n=$VERSION_CODENAME-backports" >> /etc/apt/preferences.d/90_zfs && \
      echo "Pin-Priority: 990" >> /etc/apt/preferences.d/90_zfs \
    ) && \
    apt-get update && \
    # Install zrepl and its user-land ZFS utils dependency
    apt-get install --yes --no-install-recommends zrepl zfsutils-linux && \
    # zrepl expects /var/run/zrepl
    mkdir -p /var/run/zrepl && chmod 0700 /var/run/zrepl && \
    # Reduce final Docker image size: Clear the APT cache
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    # check versions
    zrepl version 2>/dev/null || true && \
    zfs --version 2>/dev/null || true

CMD ["daemon"]
ENTRYPOINT ["/usr/bin/zrepl", "--config", "/etc/zrepl/zrepl.yml"]

VOLUME /etc/zrepl
WORKDIR "/etc/zrepl"
