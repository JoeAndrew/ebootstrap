# Copyright (c) 2015 Bruce Schultz <brulzki@gmail.com>
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: ebootstrap
# @AUTHOR:
# Bruce Schultz <brulzki@gmail.com>
# @BLURB: A eclass for bootstrapping a system using portage.
# @DESCRIPTION:
# This eclass overrides the ebuild phases to bootstrap a gentoo
# installation.

# Environment variables used in processing the TARGET configuration:
#
# E_PROFILE   - used to set the symlink for /etc/portage/make.profile
#               eg E_PROFILE=gentoo:default/linux/x86/13.0
#
# E_PORTDIR   .
# E_DISTDIR   .
# E_PKGDIR    .
#             - these are used to configure /etc/portage/make.conf
#
# TIMEZONE    - used to set the /etc/timezone
#               eg TIMEZONE="Australia/Brisbane"
#
# LOCALE_GEN  - used to set /etc/locale.gen; a space separated list
#               of locales to append to the file
#               eg LOCALE_GEN="en_AU.UTF-8 en_AU.ISO-8859-1"
#               (note the use of the '.' in each locale)

if [[ ! ${_EBOOTSTRAP} ]]; then

# this results in very ungraceful errors, but prevents any major stuff-ups
if [[ "${EBUILD_PHASE}" != "info" ]]; then
	[[ ${EROOT} == "/" ]] && die "refusing to ebootstrap /"
fi

S=${EROOT}

EXPORT_FUNCTIONS pkg_info src_unpack src_configure pkg_preinst

#DEFAULT_REPO=${DEFAULT_REPO:-gentoo}
: ${DEFAULT_REPO:=gentoo}

# load the ebootstrap library functions
source ${EBOOTSTRAP_LIB}/ebootstrap.sh

ebootstrap_src_unpack() {
	debug-print-function ${FUNCNAME} "${@}"

	# this is also checked in ebootstrap-unpack, but we want to be sure
	[[ ${EROOT} == "/" ]] && die "ERROR: refusing to install into /"

	ebootstrap-unpack ${DISTDIR}/${A}
}

ebootstrap_src_configure() {
	ebootstrap-configure
}

ebootstrap_pkg_info() {
	echo EROOT=${EROOT}
	echo "WORKDIR=${WORKDIR}"
	echo "S=${S}"
	echo "ARCH=${ARCH}"
}

ebootstrap_pkg_preinst() {
	die "ebootstrap ebuilds can not be merged into a system"
}

# trace phase functions which have not been implemented
for _f in src_unpack  \
	  src_configure src_compile src_test src_install \
	  pkg_preinst pkg_postinst pkg_prerm pkg_postrm pkg_config; do
	# only override if the function is not already defined
	if ! type ebootstrap_${_f} >/dev/null 2>&1; then
		eval "ebootstrap_${_f}() {
			ewarn \"${_f}() is not implemented\"
		}"
		EXPORT_FUNCTIONS ${_f}
	fi
done
unset _f

_EBOOTSTRAP=1
fi