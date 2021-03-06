# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#
#  Copyright © 2011-2013 Andrey Ovcharov <sudormrfhalt@gmail.com>
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#  The latest version of this software can be obtained here:
#
#  https://github.com/init6/init_6/blob/master/eclass/geek-cjktty.eclass
#
#  Bugs: https://github.com/init6/init_6/issues
#
#  Wiki: https://github.com/init6/init_6/wiki/geek-sources
#

inherit geek-patch geek-utils

EXPORT_FUNCTIONS src_unpack src_prepare pkg_postinst

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
geek-cjktty_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	OLDIFS="$IFS"
	VER="${PV}"
	IFS='.'
	set -- ${VER}
	IFS="${OLDIFS}"

	# the kernel version (e.g 3 for 3.4.2)
	VERSION="${1}"
	# the kernel patchlevel (e.g 4 for 3.4.2)
	PATCHLEVEL="${2}"
	# the kernel sublevel (e.g 2 for 3.4.2)
	SUBLEVEL="${3}"
	# the kernel major version (e.g 3.4 for 3.4.2)
	KMV="${1}.${2}"

	: ${CJKTTY_VER:=${CJKTTY_VER:-$KMV}}

	: ${CJKTTY_SRC:=${CJKTTY_SRC:-"https://github.com/Gentoo-zh/linux-cjktty/compare/torvalds:v${CJKTTY_VER/KMV/$KMV}...${CJKTTY_VER/KMV/$KMV}-utf8.diff"}}

	: ${CJKTTY_URL:=${CJKTTY_URL:-"https://github.com/Gentoo-zh/linux-cjktty"}} # http://sourceforge.net/projects/cjktty

	: ${CJKTTY_INF:=${CJKTTY_INF:-"${YELLOW}CJK support for tty framebuffer vt - ${CJKTTY_URL}${NORMAL}"}}
}

geek-cjktty_init_variables

HOMEPAGE="${HOMEPAGE} ${CJKTTY_URL}"

#SRC_URI="${SRC_URI}
#	cjktty?	( ${CJKTTY_SRC} )"

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
geek-cjktty_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	local CSD="${GEEK_STORE_DIR}/cjktty"
	local CWD="${T}/cjktty"
	shift
	test -d "${CWD}" >/dev/null 2>&1 && cd "${CWD}" || mkdir -p "${CWD}"; cd "${CWD}"
	dest="${CWD}"/cjktty-"${PV}"-`date +"%Y%m%d"`.patch
	wget "${CJKTTY_SRC}" -O "${dest}" > /dev/null 2>&1
	cd "${CWD}" || die "${RED}cd ${CWD} failed${NORMAL}"
	ls -1 | grep ".patch" | xargs -I{} xz "{}" | xargs -I{} cp "{}" "${CWD}"
	ls -1 "${CWD}" | grep ".patch.xz" > "${CWD}"/patch_list
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
geek-cjktty_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	ApplyPatch "${T}/cjktty/patch_list" "${CJKTTY_INF}"
	mv "${T}/cjktty" "${WORKDIR}/linux-${KV_FULL}-patches/cjktty" || die "${RED}mv ${T}/cjktty ${WORKDIR}/linux-${KV_FULL}-patches/cjktty failed${NORMAL}"
#	rsync -avhW --no-compress --progress "${T}/cjktty/" "${WORKDIR}/linux-${KV_FULL}-patches/cjktty" || die "${RED}rsync -avhW --no-compress --progress ${T}/cjktty/ ${WORKDIR}/linux-${KV_FULL}-patches/cjktty failed${NORMAL}"
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
geek-cjktty_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo "${CJKTTY_INF}"
}
