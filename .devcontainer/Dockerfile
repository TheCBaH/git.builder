ARG OS_VER=latest
FROM debian:${OS_VER}
RUN set -eux;\
    apt-get update;\
    env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends\
  asciidoc\
  autoconf\
  autopoint\
  automake\
  build-essential\
  ca-certificates\
  docbook-xsl-ns\
  gettext\
  git\
  po4a\
  libtool\
  libcurl4-openssl-dev\
  libexpat1-dev\
  libssl-dev\
  libz-dev\
  xmlto\
  xz-utils\
;\
    apt-get clean; rm -rf /var/lib/apt/lists/*;\
    echo DONE
