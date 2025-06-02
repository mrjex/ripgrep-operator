# Use Ubuntu 22.04 as base image
FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Enable systemd
ENV container docker
STOPSIGNAL SIGRTMIN+3

# Install required packages
RUN apt-get update && apt-get install -y \
    systemd \
    systemd-sysv \
    snapd \
    curl \
    wget \
    git \
    python3 \
    python3-pip \
    sudo \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Setup systemd
RUN cd /lib/systemd/system/sysinit.target.wants/ \
    && rm $(ls | grep -v systemd-tmpfiles-setup) \
    && rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/basic.target.wants/* \
    /lib/systemd/system/anaconda.target.wants/* \
    /lib/systemd/system/plymouth* \
    /lib/systemd/system/systemd-update-utmp*

# Create workspace directory
RUN mkdir -p /workspace/ripgrep-operator

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Mount points for systemd
VOLUME [ "/sys/fs/cgroup", "/tmp", "/run", "/run/lock" ]

# Set working directory
WORKDIR /workspace/ripgrep-operator

# Use systemd as entrypoint
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/lib/systemd/systemd"]
