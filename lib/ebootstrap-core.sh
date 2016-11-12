# Copyright (c) 2016 Bruce Schultz <brulzki@gmail.com>
# Distributed under the terms of the GNU General Public License v2

# @AUTHOR:
# Bruce Schultz <brulzki@gmail.com>
# @BLURB: Core functions for ebootstrap
# @DESCRIPTION:
# Implements core functions used by ebootstrap.

if [[ ! ${_EBOOTSTRAP_CORE} ]]; then

: ${EMERGE_OPTS:="--ask --verbose"}

__is_fn() {
    #declare -f "${1}" > /dev/null
    type -f "${1}" > /dev/null 2>&1
}

__is_fn einfo || \
einfo() {
    echo "$@"
}

__is_fn ewarn || \
ewarn() {
    echo "$@"
}

__is_fn eerror || \
eerror() {
    echo "$@"
}

__is_fn die || \
die() {
    [ ${#} -eq 0 ] || eerror "${*}"
    exit 2
}

# helper functions

# Find the appropriate user config file path
xdg-config-dir() {
    # if script is run through sudo, the load the original users config
    # instead of the root user
    if [[ -n $SUDO_USER ]]; then
        local HOME=$(eval echo ~${SUDO_USER})
    fi

    echo ${XDG_CONFIG_HOME:-$HOME/.config}/ebootstrap
}

load-global-config() {
    # the global config is loaded from
    #  - /etc/ebootstrap.conf
    #  - $XDG_CONFIG_HOME/ebootstrap/config

    local user_config=$(xdg-config-dir)/config

    if [[ -f "/etc/ebootstrap.conf" ]]; then
        source /etc/ebootstrap.conf
    fi
    if [[ -f ${user_config} ]]; then
        source ${user_config}
    fi

    # this should always be set... use default values otherwise
    : ${DISTDIR:=/var/cache/ebootstrap}
}

find-config-file() {
    local name=${1} config
    local config_dir=$(xdg-config-dir)

    case ${name} in
        /* | ./*)
            [[ -f ${name} ]] && config=${name};
            ;;
        *)
            if [[ -f ${name} ]]; then
                config=$(readlink -m ${1})
            elif [[ -f ${0%/*}/config/${1}.eroot ]]; then
                config=$(readlink -m ${0%/*}/config/${1}.eroot)
            elif [[ -f ${config_dir}/${1}.eroot ]]; then
                config=$(readlink -m ${config_dir}/${1}.eroot)
            else
                # equery means gentoolkit must be installed
                config=$(equery which ${1} 2>/dev/null)
            fi
            ;;
    esac

    [[ -n "${config}" ]] && echo "${config}" || false
}

ebootstrap-emerge() {
    # call the system emerge with options tailored to use within ebootstrap
    debug-print-function ${FUNCNAME} "${@}"

    FEATURES="-news" /usr/bin/emerge --root=${EROOT} --config-root=${EROOT} ${EMERGE_OPTS} "$@"
}

_EBOOTSTRAP_CORE=1
fi
