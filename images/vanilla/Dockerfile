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

ENV DL_VERSION=1423
ENV DL_FILE=terraria-server-$DL_VERSION.zip
ENV DL_LINK=https://terraria.org/api/download/pc-dedicated-server/$DL_FILE

# Download and unpack
ADD $DL_LINK /$DL_FILE
RUN unzip /$DL_FILE -d /terraria && \
  mkdir /terraria-server && \
  mv /terraria/$DL_VERSION/Linux/* /terraria-server && \
  chmod +x /terraria-server/TerrariaServer.exe && \
  chmod +x /terraria-server/TerrariaServer.bin.x86_64

FROM mono:6.8.0.96-slim

LABEL maintainer="Seppe Volkaerts <contact@seppevolkaerts.be>"

EXPOSE 7777

COPY --from=base /terraria-server /terraria-server
COPY bootstrap.sh /terraria-server

RUN groupadd terraria -g 1000 && \
  useradd terraria -m -u 1000 -g 1000 && \
  apt-get update -y && \
  apt-get install -y pcregrep && \
  rm -rf /var/lib/apt/lists* /tmp* && \
  mkdir /terraria-server/tmp && \
  chown terraria:terraria /terraria-server/tmp

WORKDIR /home/terraria/server

RUN chown -R terraria:terraria .

USER terraria

VOLUME [ "/home/terraria/server/worlds"  ]
VOLUME [ "/home/terraria/server/logs"    ]
VOLUME [ "/home/terraria/server/config"  ]

RUN mkdir worlds && \
  mkdir logs && \
  mkdir config

ENTRYPOINT [ "/bin/sh", "/terraria-server/bootstrap.sh" ]
