FROM debian:stretch

ARG DEBIAN_FRONTEND="noninteractive"

COPY ./docker-entrypoint.sh /docker-entrypoint.sh

# Install build packages
RUN apt-get update -qq && \
    apt-get install -qy \
        software-properties-common \
        gnupg \
        wget \
        xz-utils && \
    add-apt-repository ppa:jonathonf/ffmpeg-3 && \
    apt-get install -qy \
        ffmpeg \
        libav-tools \
        x264 \
        x265 && \

# Create user
    useradd -u 911 -U -d /config -s /bin/false duser && \
    usermod -G users duser && \
    groupmod -o -g 100 duser && \
    usermod -o -u 99 duser && \

# Install emby-server
    wget -nv -O /tmp/Release.key http://download.opensuse.org/repositories/home:emby/Debian_9.0/Release.key && \
    apt-key add - < /tmp/Release.key && \
    echo 'deb http://download.opensuse.org/repositories/home:/emby/Debian_9.0/ /' >> /etc/apt/sources.list.d/emby-server.list && \
    apt-get update -qq && \
    apt-get install -qy --no-install-recommends procps emby-server && \

# Cleanup
    apt-get purge -qq \
        gnupg \
        wget \
        xz-utils && \
    apt-get -y autoremove --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \

# Set file permissions
    chmod +x /docker-entrypoint.sh

# set Directories
VOLUME ["/config","/media"]

ENTRYPOINT ["/docker-entrypoint.sh"]

