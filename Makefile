ID_OFFSET=$(or $(shell id -u docker 2>/dev/null),0)
UID=$(shell expr $$(id -u) - ${ID_OFFSET})
GID=$(shell expr $$(id -g) - ${ID_OFFSET})
USER=$(shell id -un)
GROUP=$(shell id -gn)
WORKSPACE=$(or ${LOCAL_WORKSPACE_FOLDER},${CURDIR})
TERMINAL=$(shell test -t 0 && echo t)

USERSPEC=--user=${UID}:${GID}
image_name=${USER}_$(basename $(1))

all:
	echo 'Not supported' >&2

image_name=${USER}_$(basename $(1))

%.image: Dockerfile-%
	docker build --tag $(call image_name,$@) ${DOCKER_BUILD_OPTS} -f $^\
	 --build-arg USERINFO=${USER}:${UID}:${GROUP}:${GID}:${KVM}\
	 $(if ${http_proxy},--build-arg http_proxy=${http_proxy})\
	 .

%.image_run:
	docker run --rm --init --hostname $@ -i${TERMINAL} -w ${WORKSPACE} -v ${WORKSPACE}:${WORKSPACE}\
	 ${DOCKER_RUN_OPTS}\
	 ${USERSPEC} $(call image_name, $@) ${CMD}

%.image_print:
	@echo "$(call image_name, $@)"

repo: GIT_VER=2.39.2
repo:
	./repo.sh init
	./repo.sh update v${GIT_VER}

ifdef WITH_STATIC
LDFLAGS:=-static --static
export LDFLAGS
endif

CURL_CONFIG=$(realpath ${CURDIR}/.local/bin/curl-config)
ifneq (${CURL_CONFIG},)
git.configure: CONFIG=env\
 CFLAGS="${CFLAGS} -Wno-cpp $$(${CURL_CONFIG} --cflags)"\
 CURL_CONFIG="${CURDIR}/.local/bin/curl-config"\
 CURL_DIR="${CURDIR}/.local/"\
 LDFLAGS="${LDFLAGS} $$(${CURL_CONFIG} --libs)"\
 LIBS="$$(${CURL_CONFIG} --static-libs)"
endif

git.configure:
	${MAKE} -C $(basename $@) configure
	set -eux;cd $(basename $@);${CONFIG} ./configure --prefix /usr/local\
	 --with-curl\
	 --with-expat\
	 --with-openssl\
	 --without-iconv\
	 --without-python\
	 --without-tcltk\
	 ;
	cat git/config.log

CPUS=$(or $(shell getconf _NPROCESSORS_ONLN 2>/dev/null),1)
git.build:
	${MAKE} -C $(basename $@) all -j${CPUS} $(if ${CURL_CONFIG},\
	 CURL_LIBCURL="$$(${CURL_CONFIG} --libs) $$(${CURL_CONFIG} --static-libs)"\
	 CURL_LDFLAGS="$$(${CURL_CONFIG} --libs) $$(${CURL_CONFIG} --static-libs)"\
	 ) V=1
	${MAKE} -C $(basename $@) strip -j${CPUS}

git.doc:
	${MAKE} -C $(basename $@) doc -j${CPUS}

export NO_PERL=1

git.test:
	git/git -C git --version

git.test.installed:
	/usr/local/bin/git -C git ls-remote

git.install:
	${MAKE} -C $(basename $@) install install-doc

INSTALL_DIR=.install

git.install.prepare:
	set -eux; rm -rf ${INSTALL_DIR}; mkdir -p ${INSTALL_DIR}

git.install.alpine: git.install.prepare
	${MAKE}\
	 CMD='${MAKE} $(basename $@)'\
	 DOCKER_RUN_OPTS='-v ${WORKSPACE}/${INSTALL_DIR}:/usr/local'\
	 alpine.image_run

git.install.sudo: git.install.prepare
	./with-bind_mount.sh $(abspath ${INSTALL_DIR}) /usr/local ${MAKE} $(basename $@)

git.test.installed.sudo:
	./with-bind_mount.sh $(abspath ${INSTALL_DIR}) /usr/local ${MAKE} $(basename $@)

curl.configure:
	set -eux;\
	  cd .modules/curl;\
	  autoreconf -fi;\
	  env\
	    PKG_CONFIG="pkg-config --static"\
	    ./configure\
	      --disable-ldap\
	      --disable-shared\
	      --enable-static\
	      --prefix=${CURDIR}/.local\
	      --with-openssl\
	      --without-libidn2\
	      --without-libssh2\

curl.build:
	${MAKE} -C .modules/curl -j${CPUS} V=1

curl.install:
	${MAKE} -C .modules/curl -j${CPUS} install-strip

curl: $(addprefix curl., configure build install)

xz.autogen:
	cd .modules/xz && ./autogen.sh;

xz.configure:
	cd .modules/xz && ./configure --prefix=${CURDIR}/.local

xz.build:
	${MAKE} -C .modules/xz -j${CPUS}

xz.install:
	${MAKE} -C .modules/xz install-strip

xz: $(addprefix xz., autogen configure build install)

openssh.autogen:
	cd .modules/openssh-portable && autoreconf

openssh.configure:
	cd .modules/openssh-portable && ./configure

openssh.build:
	${MAKE} -C .modules/openssh-portable -j${CPUS}

openssh.install:
	${MAKE} -C .modules/openssh-portable install DESTDIR=${CURDIR}/.local

openssh: $(addprefix openssh., autogen configure build install)
