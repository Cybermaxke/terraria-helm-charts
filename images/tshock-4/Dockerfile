#  The MIT License (MIT)
#
#  Copyright (c) Seppe Volkaerts <https://seppevolkaerts.be>
#  Copyright (c) 2015 Ryan Sheehan
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in all
#  copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#  SOFTWARE.

FROM alpine:latest AS base

RUN apk add --update-cache unzip

ARG TERRARIA_VERSION=1.4.3.6
ARG TSHOCK_VERSION=4.5.18

# Download and unpack TShock
RUN RELEASES="https://github.com/Pryaxis/TShock/releases/download" && \
  (wget "$RELEASES/v$TSHOCK_VERSION/TShock${TSHOCK_VERSION}_Terraria${TERRARIA_VERSION}.zip" -O /tshock.zip || \
   wget "$RELEASES/v$TSHOCK_VERSION/TShock${TSHOCK_VERSION}_Terraria_${TERRARIA_VERSION}.zip" -O /tshock.zip) && \
  unzip /tshock.zip -d /tshock && \
  rm /tshock.zip && \
  chmod +x /tshock/TerrariaServer.exe

# Cannot be the slim version, plugins may have dependencies
FROM mono:6.12

LABEL org.opencontainers.image.authors="Seppe Volkaerts <contact@seppevolkaerts.be>"
LABEL org.opencontainers.image.url="https://github.com/Cybermaxke/terraria-helm-charts"
LABEL org.opencontainers.image.documentation="tShock $TSHOCK_VERSION for Terraria $TERRARIA_VERSION"
LABEL org.opencontainers.image.source="https://github.com/Cybermaxke/terraria-helm-charts/blob/master/images/tshock/Dockerfile"

# Server port
EXPOSE 7777

# Rest API port
EXPOSE 7878

COPY --from=base /tshock /tshock
COPY bootstrap.sh /tshock

ARG TERRARIA_GID=1000
ARG TERRARIA_UID=1000

RUN groupadd terraria -g $TERRARIA_GID && \
  useradd terraria -m -u $TERRARIA_UID -g $TERRARIA_GID && \
  apt-get update -y && \
  # Install nuget to grab TShock dependencies
  apt-get install -y nuget pcregrep && \
  rm -rf /var/lib/apt/lists* /tmp/* && \
  # The bootstrap script needs to be able to copy plugins to the ServerPlugins directory
  chown terraria:terraria /tshock/ServerPlugins && \
  mkdir /tshock/tmp && \
  chown terraria:terraria /tshock/tmp && \
  chmod +x /tshock/bootstrap.sh

WORKDIR /home/terraria/server

RUN chown -R terraria:terraria .

USER terraria

VOLUME [ "/home/terraria/server/worlds"  ]
VOLUME [ "/home/terraria/server/logs"    ]
VOLUME [ "/home/terraria/server/plugins" ]
VOLUME [ "/home/terraria/server/config"  ]
VOLUME [ "/home/terraria/server/tshock"  ]

RUN mkdir worlds && \
  mkdir logs && \
  mkdir config && \
  mkdir plugins && \
  mkdir tshock

ENTRYPOINT [ "/bin/sh", "/tshock/bootstrap.sh" ]
