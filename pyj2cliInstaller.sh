#!/bin/bash
export GPG_KEY="0D96DF4D4110E5C43FBFB17F2D347EA6AA65421D"
export PATH="/usr/local/bin:$PATH"
export LANG="C.UTF-8"
export PYTHON_VERSION="3.7.0"
export PYTHON_PIP_VERSION="18.0"

apk add --no-cache ca-certificates
set -ex
apk add --no-cache --virtual .fetch-deps gnupg openssl tar xz
wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz"
wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc"

export GNUPGHOME="$(mktemp -d)"

gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY"
gpg --batch --verify python.tar.xz.asc python.tar.xz
{ command -v gpgconf > /dev/null && gpgconf --kill all || :; }
rm -rf "$GNUPGHOME" python.tar.xz.asc

mkdir -p /usr/src/python
tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz
rm python.tar.xz
apk add --no-cache --virtual .build-deps bzip2-dev coreutils dpkg-dev dpkg expat-dev findutils gcc gdbm-dev libc-dev libffi-dev libnsl-dev openssl openssl-dev libtirpc-dev linux-headers make ncurses-dev pax-utils readline-dev sqlite-dev tcl-dev tk tk-dev xz-dev zlib-dev
apk del .fetch-deps

cd /usr/src/python
gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"
./configure --build="$gnuArch" --enable-loadable-sqlite-extensions --enable-shared --with-system-expat --with-system-ffi --without-ensurepip
make -j "$(nproc)" EXTRA_CFLAGS="-DTHREAD_STACK_SIZE=0x100000"
make install
find /usr/local -type f -executable -not \( -name '*tkinter*' \) -exec scanelf --needed --nobanner --format '%n#p' '{}' ';' | tr ',' '\n' | sort -u | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' | xargs -rt apk add --virtual .python-rundeps
apk del .build-deps
find /usr/local -depth \( \( -type d -a \( -name test -o -name tests \) \) -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \) -exec rm -rf '{}' + 
rm -rf /usr/src/python
python3 --version

cd /usr/local/bin
ln -s idle3 idle
ln -s pydoc3 pydoc
ln -s python3 python
ln -s python3-config python-config

set -ex
apk add --no-cache --virtual .fetch-deps openssl
wget -O get-pip.py 'https://bootstrap.pypa.io/get-pip.py'
apk del .fetch-deps
python get-pip.py --disable-pip-version-check --no-cache-dir "pip==$PYTHON_PIP_VERSION"
pip --version
find /usr/local -depth \( \( -type d -a \( -name test -o -name tests \) \) -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \) -exec rm -rf '{}' +
rm -f get-pip.py

pip install j2cli