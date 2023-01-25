FROM debian:bullseye

COPY ./data/backports.list /etc/apt/sources.list.d/bullseye-backports.list
COPY ./data/apt-preferences /etc/apt/preferences.d/90_zfs
  
RUN \
  DEBIAN_FRONTEND=noninteractive && \
  apt update && \
  apt install -y dpkg-dev linux-headers-generic linux-image-generic && \
  apt install -y zfs-dkms zfsutils-linux && \
  rm -rf /var/lib/apt/lists/*

RUN \
  DEBIAN_FRONTEND=noninteractive && \
  zrepl_apt_key_url=https://zrepl.cschwarz.com/apt/apt-key.asc && \
  zrepl_apt_key_dst=/usr/share/keyrings/zrepl.gpg && \
  zrepl_apt_repo_file=/etc/apt/sources.list.d/zrepl.list && \
  # Install dependencies for subsequent commands
  sudo apt update && sudo apt install -y curl gnupg lsb-release && \
  # Deploy the zrepl apt key.
  curl -fsSL "$zrepl_apt_key_url" | tee | gpg --dearmor | sudo tee "$zrepl_apt_key_dst" > /dev/null && \
  # Add the zrepl apt repo.
  ARCH="$(dpkg --print-architecture)" && \
  CODENAME="$(lsb_release -i -s | tr '[:upper:]' '[:lower:]') $(lsb_release -c -s | tr '[:upper:]' '[:lower:]')" && \
  echo "Using Distro and Codename: $CODENAME" && \
  echo "deb [arch=$ARCH signed-by=$zrepl_apt_key_dst] https://zrepl.cschwarz.com/apt/$CODENAME main" | sudo tee /etc/apt/sources.list.d/zrepl.list && \
  # Update apt repos.
  apt update && \
  apt install -y zrepl && \
  rm -rf /var/lib/apt/lists/*

CMD [ "/usr/bin/zrepl" ]
