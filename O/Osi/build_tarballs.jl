using BinaryBuilder, Pkg

name = "Osi"
version = v"0.108.6"

# Collection of sources required to build OsiBuilder
sources = [
    GitSource("https://github.com/coin-or/Osi.git",
              "dfa6449d6756fdd96912cf96e168d0be07b1d37c")
]

script = raw"""
cd $WORKSPACE/srcdir/Osi*
update_configure_scripts

mkdir build
cd build/

export CPPFLAGS="${CPPFLAGS} -I${prefix}/include"
export CXXFLAGS="${CXXFLAGS} -std=c++11"
if [[ ${target} == *mingw* ]]; then	
    export LDFLAGS="-L$prefix/bin"
elif [[ ${target} == *linux* ]]; then
    export LDFLAGS="-ldl -lrt"
fi

../configure --prefix=$prefix --with-pic --disable-pkg-config --build=${MACHTYPE} --host=${target} --enable-shared \
--enable-dependency-linking lt_cv_deplibs_check_method=pass_all \
--with-coinutils-lib="-lCoinUtils" --with-coinutils-incdir="$prefix/include/coin" \
--with-blas-lib="-lopenblas" --with-lapack-lib="-lopenblas"

make -j${nproc}
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = expand_cxxstring_abis(supported_platforms())
platforms = [p for p in platforms if !(typeof(p) <: FreeBSD)]
platforms = [p for p in platforms if !(arch(p) == :powerpc64le)]

# The products that we will ensure are always built
products = [
    LibraryProduct(["libOsi", "libOsi-1"], :libOsi), 
    LibraryProduct(["libOsiCommonTests", "libOsiCommonTests-1"], :libOsiCommonTests),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    Dependency(PackageSpec(; name = "CoinUtils_jll", uuid = "be027038-0da8-5614-b30d-e42594cb92df", version = v"2.11.4")),
    Dependency("OpenBLAS32_jll"),
    Dependency("CompilerSupportLibraries_jll"),
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies; preferred_gcc_version=v"6")
