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

FROM alpine:3.14.2 AS base

RUN apk add --update-cache unzip

ENV TSHOCK_VERSION=v4.5.5
ENV TSHOCK_ZIP=TShock4.5.5_Terraria_1.4.2.3.zip

# Download and unpack TShock
ADD https://github.com/Pryaxis/TShock/releases/download/$TSHOCK_VERSION/$TSHOCK_ZIP /
RUN unzip $TSHOCK_ZIP -d /tshock && \    
  rm $TSHOCK_ZIP && \
  chmod +x /tshock/TerrariaServer.exe

# Cannot be the slim version, plugins may have dependencies
FROM mono:6.12.0.107

LABEL maintainer="Seppe Volkaerts <contact@seppevolkaerts.be>"

# Server port
EXPOSE 7777

# Rest API port
EXPOSE 7878

COPY --from=base /tshock /tshock
COPY bootstrap.sh /tshock

RUN groupadd terraria -g 1000 && \
  useradd terraria -m -u 1000 -g 1000 && \
  apt-get update -y && \
  # Install nuget to grab TShock dependencies
  apt-get install -y nuget pcregrep && \
  rm -rf /var/lib/apt/lists* /tmp* && \
  # The bootstrap script needs to be able to copy plugins to the ServerPlugins directory
  chown terraria:terraria /tshock/ServerPlugins && \
  mkdir /tshock/tmp && \
  chown terraria:terraria /tshock/tmp

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
