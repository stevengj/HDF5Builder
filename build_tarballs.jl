using BinaryBuilder, Compat

# Collection of sources required to build HDF5.  Use the CMake download because
# it includes appropriate zlib and szip sources, letting us build them into libhdf5.
sources = [
    "https://support.hdfgroup.org/ftp/HDF5/current18/src/CMake-hdf5-1.8.20.tar.gz" =>
    "1edc45f5065597a72ecf0663786c07aa89ecb4cfbaf025496c399b5ab1b6085e"
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/CMake-hdf5-*
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=$prefix \
      -DCMAKE_TOOLCHAIN_FILE=/opt/$target/$target.toolchain -DCMAKE_SYSTEM_PROCESSOR=$(uname -p) \
      -DBUILD_SHARED_LIBS=ON -DH5_ENABLE_STATIC_LIB=OFF \
      -DHDF5_BUILD_CPP_LIB=OFF -DHDF5_BUILD_FORTRAN=OFF -DHDF5_ENABLE_PARALLEL=OFF \
      -DBUILD_TESTING=OFF -DHDF5_BUILD_TOOLS=OFF -DHDF5_BUILD_EXAMPLES=OFF -DHDF5_BUILD_HL_LIB=OFF \
      -DHDF5_PACKAGE_EXTLIBS=ON -DHDF5_ALLOW_EXTERNAL_SUPPORT=TGZ -DTGZPATH=`pwd`/.. \
      -DHDF5_ENABLE_SZIP_SUPPORT=ON -DSZIP_TGZ_NAME="SZip.tar.gz" -DSZIP_PACKAGE_NAME=szip \
      -DHDF5_ENABLE_Z_LIB_SUPPORT=ON -DZLIB_TGZ_NAME="ZLib.tar.gz" -DZLIB_PACKAGE_NAME=zlib \
      ../hdf5-*
make || cp bin/libszip-static.a bin/libszip.a # work around apparent bug in their makefile
make && make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = supported_platforms() # build on all supported platforms

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libhdf5-shared", :libhdf5),
]

# Dependencies that must be installed before this package can be built
dependencies = [
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, "HDF5", sources, script, platforms, products, dependencies)
