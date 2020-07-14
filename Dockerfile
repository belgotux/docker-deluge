# Deluge v1 version for windows client, based on S6 overlay script and lsiobase for deluge init script

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Deluge v1 version for windows client version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="belgotux"
ARG BUILD_VERSION
FROM debian:${BUILD_VERSION}-slim

# environment variables
ARG DEBIAN_FRONTEND="noninteractive"
ENV PYTHON_EGG_CACHE="/config/plugins/.python-eggs"

# Default ENV
ENV \
    LANG="C.UTF-8" \
    DEBIAN_FRONTEND="noninteractive" \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_CMD_WAIT_FOR_SERVICES=1 \
    HOME="/root" \
#from linuxserver
    LANGUAGE="en_US.UTF-8" \
    LANG="en_US.UTF-8" \
    TERM="xterm"

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Base system
ARG BASHIO_VERSION=0.9.0
ARG S6_OVERLAY_VERSION=2.0.0.1
RUN apt-get update && apt-get install -y --no-install-recommends \
        bash \
        jq \
        tzdata \
        curl \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /usr/share/man/man1 \
    \
    && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz" \
        | tar zxvf - -C / \
    && mkdir -p /etc/fix-attrs.d \
    && mkdir -p /etc/services.d \
    \
    && mkdir -p /tmp/bashio \
    && curl -L -s https://github.com/hassio-addons/bashio/archive/v${BASHIO_VERSION}.tar.gz | tar -xzf - --strip 1 -C /tmp/bashio \
    && mv /tmp/bashio/lib /usr/lib/bashio \
    && ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
    && rm -rf /tmp/bashio \
# install software
    && echo "**** install packages ****" \
    && sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y \
	     deluged \
	     deluge-console \
	     deluge-web \
	     python3-future \
	     python3-requests \
	     p7zip-full \
	     unrar \
	     unzip \
    && echo "**** cleanup ****" \
    && rm -rf \
	     /tmp/* \
	     /var/lib/apt/lists/* \
	     /var/tmp/*


# S6-Overlay
ENTRYPOINT ["/init"]

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8112 58846 58946 58946/udp
VOLUME /config /downloads

