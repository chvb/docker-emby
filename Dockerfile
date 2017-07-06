FROM debian:stretch

ARG DEBIAN_FRONTEND="noninteractive"

COPY ./docker-entrypoint.sh /docker-entrypoint.sh

WORKDIR /work

ENV TARGET_VERSION=3.3 \
    LIBVA_VERSION=1.8.1 \
    LIBDRM_VERSION=2.4.80 \

# Install build packages
RUN apt-get update -qq && \
    apt-get install -qy \
        gnupg \
        wget \
        cmake \
        make \
        xz-utils && \

# Create user
    useradd -u 911 -U -d /config -s /bin/false duser && \
    usermod -G users duser && \
    groupmod -o -g 100 duser && \
    usermod -o -u 99 duser && \

# Build libva
    DIR=$(mktemp -d) && cd ${DIR} && \
    curl -sL https://www.freedesktop.org/software/vaapi/releases/libva/libva-${LIBVA_VERSION}.tar.bz2 | \
    tar -jx --strip-components=1 && \
    ./configure CFLAGS=' -O2' CXXFLAGS=' -O2' --prefix=${SRC} && \
    make && make install && \
    rm -rf ${DIR} && \
    
# Build libva-intel-driver
    DIR=$(mktemp -d) && cd ${DIR} && \
    curl -sL https://www.freedesktop.org/software/vaapi/releases/libva-intel-driver/intel-vaapi-driver-${LIBVA_VERSION}.tar.bz2 | \
    tar -jx --strip-components=1 && \
    ./configure && \
    make && make install && \

# Build ffmpeg
    DIR=$(mktemp -d) && cd ${DIR} && \
    curl -sL http://ffmpeg.org/releases/ffmpeg-${TARGET_VERSION}.tar.gz | \
    tar -zx --strip-components=1 && \
    ./configure \
        --prefix=${SRC} \
        --enable-small \
        --enable-gpl \
        --enable-vaapi \
        --disable-doc \
        --disable-debug && \
    make && make install && \
    make distclean && \
    hash -r && \

# Install emby-server
    wget -nv -O /tmp/Release.key http://download.opensuse.org/repositories/home:emby/Debian_9.0/Release.key && \
    apt-key add - < /tmp/Release.key && \
    echo 'deb http://download.opensuse.org/repositories/home:/emby/Debian_9.0/ /' >> /etc/apt/sources.list.d/emby-server.list && \
    apt-get update -qq && \
    apt-get install -qy --no-install-recommends procps emby-server && \

# Cleanup
    rm -rf ${DIR} && \
    apt-get purge -qq \
        gnupg \
        wget \
        xz-utils && \
    apt-get -y autoremove --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \

# Set file permissions
    chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
