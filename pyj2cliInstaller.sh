#!/bin/bash
#############################################
# Installler Python and j2cli
#############################################

export GPG_KEY="C01E1CAD5EA2C4F0B8E3571504C367C218ADD4FF"
export PATH="/usr/local/bin:$PATH"
export LANG="C.UTF-8"
export PYTHON_VERSION="2.7.15"
export PYTHON_PIP_VERSION="10.0.1"

#############################################
# Install Python
#############################################
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
./configure --build="$gnuArch" --enable-shared --enable-unicode=ucs4
make -j "$(nproc)" EXTRA_CFLAGS="-DTHREAD_STACK_SIZE=0x100000"
make install
find /usr/local -type f -executable -not \( -name '*tkinter*' \) -exec scanelf --needed --nobanner --format '%n#p' '{}' ';' | tr ',' '\n' | sort -u | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' | xargs -rt apk add --virtual .python-rundeps
apk del .build-deps
find /usr/local -depth \( \( -type d -a \( -name test -o -name tests \) \) -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \) -exec rm -rf '{}' + 
rm -rf /usr/src/python
python2 --version

#############################################
# Install PIP
#############################################
set -ex
apk add --no-cache --virtual .fetch-deps openssl
wget -O get-pip.py 'https://bootstrap.pypa.io/get-pip.py'
apk del .fetch-deps
python get-pip.py --disable-pip-version-check --no-cache-dir "pip==$PYTHON_PIP_VERSION"
pip --version
find /usr/local -depth \( \( -type d -a \( -name test -o -name tests \) \) -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \) -exec rm -rf '{}' +
rm -f get-pip.py

#############################################
# Install j2cli (Jinja2 Command-Line Tool)
# https://github.com/kolypto/j2cli
#############################################
pip install j2cli