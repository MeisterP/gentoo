# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs

MY_P=${PN}-v${PV}
DESCRIPTION="Web application framework written in Lua and C"
HOMEPAGE="https://www.public-software-group.org/webmcp"
SRC_URI="https://www.public-software-group.org/pub/projects/${PN}/v${PV}/${MY_P}.tar.gz"

LICENSE="HPND"
KEYWORDS="~amd64"
SLOT=0
IUSE=""

RDEPEND="dev-lang/lua:0=
	dev-db/postgresql:="
DEPEND="${RDEPEND}"

S="${WORKDIR}"/${MY_P}

PATCHES=( "${FILESDIR}"/${P}-gentoo.patch )

src_compile() {
	emake CC=$(tc-getCC) LD=$(tc-getCC) MYLDFLAGS="${LDFLAGS}"
	# Dereference symlinks
	cd framework
	mkdir lib.link
	mv lib/* lib.link
	cp lib.link/* lib
}

src_install() {
	into /usr/lib/${PN}
	dolib.so framework/lib/*.so
	for subdir in "" ".precompiled"; do
		MY_DEST=/usr/lib/${PN}/framework${subdir}

		cd framework${subdir}
		exeinto ${MY_DEST}/accelerator
		doexe accelerator/webmcp_accelerator.so
		insinto ${MY_DEST}
		doins -r env js
		exeinto ${MY_DEST}/cgi-bin
		doexe cgi-bin/webmcp*.lua
		into ${MY_DEST}
		dobin bin/*
		insinto ${MY_DEST}/lib
		doins lib/*.lua
		cd ..

		for file in extos.so mondelefant_native.so multirand.so; do
			dosym ../../$(get_libdir)/$file ${MY_DEST}/lib/$file
		done

		insinto /usr/share/${PN}
		doins -r demo-app${subdir}
	done
	dodoc doc/*sample.conf libraries/mondelefant/example.lua
	docinto html
	dodoc doc/autodoc.html
}
