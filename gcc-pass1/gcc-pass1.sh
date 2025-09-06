#!/bin/bash
#
# gcc-pass1.sh - Construção do GCC Pass 1
# Inclui download automático, log e aplicação de patch
PRGNAM=gcc
VERSION=12.2.0
ARCH=$(uname -m)
BUILD=1
SRC_DIR=/sources
TMP=/tmp/$PRGNAM-build
PKG=$TMP/package-$PRGNAM
OUTPUT=/tmp
LOGFILE=$OUTPUT/$PRGNAM-$VERSION-build.log

# Dependências
MPFR_VERSION=4.2.1
GMP_VERSION=6.2.1
MPC_VERSION=1.3.1
ISL_VERSION=0.25
CLOOG_VERSION=0.25.0

INSTALL_PREFIX=/tools   # Diretório típico do LFS Pass 1

set -e
set -u
set -o pipefail

# Redireciona todo output para log
exec > >(tee -i $LOGFILE)
exec 2>&1

echo "=== Início do build GCC Pass 1 $(date) ==="

# Função para baixar tarball se não existir
download_if_missing() {
    local url=$1
    local dest=$2
    if [ ! -f "$dest" ]; then
        echo "Baixando $dest..."
        wget -c $url -O $dest
    else
        echo "Tarball $dest já existe, pulando download."
    fi
}

echo "=== Preparando diretório temporário ==="
rm -rf $TMP
mkdir -p $TMP $PKG $OUTPUT
cd $TMP

# Download dos tarballs
download_if_missing "http://ftp.gnu.org/gnu/gcc/$PRGNAM-$VERSION/$PRGNAM-$VERSION.tar.xz" "$SRC_DIR/$PRGNAM-$VERSION.tar.xz"
download_if_missing "http://www.mpfr.org/mpfr-current/mpfr-$MPFR_VERSION.tar.xz" "$SRC_DIR/mpfr-$MPFR_VERSION.tar.xz"
download_if_missing "https://gmplib.org/download/gmp/gmp-$GMP_VERSION.tar.xz" "$SRC_DIR/gmp-$GMP_VERSION.tar.xz"
download_if_missing "https://ftp.gnu.org/gnu/mpc/mpc-$MPC_VERSION.tar.gz" "$SRC_DIR/mpc-$MPC_VERSION.tar.gz"
download_if_missing "https://gcc.gnu.org/pub/gcc/infrastructure/isl-$ISL_VERSION.tar.xz" "$SRC_DIR/isl-$ISL_VERSION.tar.xz"
download_if_missing "https://gcc.gnu.org/pub/gcc/infrastructure/cloog-$CLOOG_VERSION.tar.gz" "$SRC_DIR/cloog-$CLOOG_VERSION.tar.gz"

echo "=== Extraindo GCC ==="
tar -xf $SRC_DIR/$PRGNAM-$VERSION.tar.xz
cd $PRGNAM-$VERSION

# Aplicar patch se existir
if compgen -G "$SRC_DIR/$PRGNAM-$VERSION-*.patch" > /dev/null; then
    for patch in $SRC_DIR/$PRGNAM-$VERSION-*.patch; do
        echo "Aplicando patch $patch"
        patch -Np1 < "$patch"
    done
fi

echo "=== Extraindo dependências ==="
tar -xf $SRC_DIR/mpfr-$MPFR_VERSION.tar.xz
mv mpfr-$MPFR_VERSION mpfr

tar -xf $SRC_DIR/gmp-$GMP_VERSION.tar.xz
mv gmp-$GMP_VERSION gmp

tar -xf $SRC_DIR/mpc-$MPC_VERSION.tar.gz
mv mpc-$MPC_VERSION mpc

tar -xf $SRC_DIR/isl-$ISL_VERSION.tar.xz
mv isl-$ISL_VERSION isl

tar -xf $SRC_DIR/cloog-$CLOOG_VERSION.tar.gz
mv cloog-$CLOOG_VERSION cloog

echo "=== Criando diretório de build ==="
mkdir -p build
cd build

echo "=== Configurando GCC Pass 1 ==="
../configure \
    --target=$ARCH-lfs-linux-gnu \
    --prefix=$INSTALL_PREFIX \
    --disable-nls \
    --enable-languages=c \
    --without-headers \
    --disable-multilib

echo "=== Compilando GCC Pass 1 ==="
make -j$(nproc) all-gcc
make -j$(nproc) all-target-libgcc

echo "=== Instalando GCC Pass 1 ==="
make install-gcc DESTDIR=$PKG
make install-target-libgcc DESTDIR=$PKG

echo "=== Criando pacote Slackware-style ==="
tar -C $PKG -cJf $OUTPUT/$PRGNAM-$VERSION-$ARCH-$BUILD.txz .

echo "=== GCC Pass 1 concluído com sucesso! ==="
echo "Pacote gerado: $OUTPUT/$PRGNAM-$VERSION-$ARCH-$BUILD.txz"
echo "Log completo: $LOGFILE"
