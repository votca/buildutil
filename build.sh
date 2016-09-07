#!/bin/bash
#
# Copyright 2009-2016 The VOTCA Development Team (http://www.votca.org)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#version 1.0.0 -- 18.12.09 initial version
#version 1.0.1 -- 21.12.09 added --pullpath option
#version 1.0.2 -- 14.01.10 improved clean
#version 1.0.3 -- 20.01.10 better error message in prefix_clean
#version 1.0.4 -- 09.02.10 added --static option
#version 1.0.5 -- 03.03.10 added pkg-config support
#version 1.0.6 -- 16.03.10 sets VOTCALDLIB
#version 1.0.7 -- 23.03.10 added --jobs/--latest
#version 1.1.0 -- 19.04.10 added --log
#version 1.1.1 -- 06.07.10 ignore VOTCALDLIB from environment
#version 1.2.0 -- 12.07.10 added -U and new shortcuts (-p,-q,-C)
#version 1.2.1 -- 28.09.10 added --no-bootstrap and --dist option
#version 1.3.0 -- 30.09.10 moved to googlecode
#version 1.3.1 -- 01.10.10 checkout stable branch by default
#version 1.3.2 -- 08.12.10 added --dist-pristine
#version 1.3.3 -- 09.12.10 allow to overwrite hg by HG
#version 1.3.4 -- 10.12.10 added --devdoc option
#version 1.3.5 -- 13.12.10 added --no-branchcheck and --no-wait option
#version 1.4.0 -- 15.12.10 added support for espressopp
#version 1.4.1 -- 17.12.10 default check for new version
#version 1.4.2 -- 20.12.10 some fixes in self_update check
#version 1.5.0 -- 11.02.11 added --longhelp and cmake support
#version 1.5.1 -- 13.02.11 removed --votcalibdir and added rpath options
#version 1.5.2 -- 16.02.11 added libtool options
#version 1.5.3 -- 17.02.11 bumped latest to 1.1_rc3
#version 1.5.4 -- 17.02.11 moved away from dev.votca.org
#version 1.5.5 -- 18.02.11 bumped latest to 1.1
#version 1.5.6 -- 01.03.11 bumped latest to 1.1.1
#version 1.5.7 -- 15.03.11 switched back to dev.votca.org
#version 1.5.8 -- 04.04.11 bumped latest to 1.1.2
#version 1.5.9 -- 16.06.11 bumped latest to 1.2
#version 1.6.0 -- 17.06.11 removed autotools support
#version 1.6.1 -- 17.06.11 added --cmake option
#version 1.6.2 -- 28.07.11 added --with-rpath option
#version 1.7.0 -- 09.08.11 added --no-rpath option and allow to build gromacs
#version 1.7.1 -- 15.08.11 added more branch checks
#version 1.7.2 -- 18.08.11 fixed a bug in clone code
#version 1.7.3 -- 25.08.11 bumped latest to 1.2.1
#version 1.7.4 -- 10.10.11 ctp renames
#version 1.7.5 -- 11.10.11 added --gui
#version 1.7.6 -- 14.10.11 do clean by default again
#version 1.7.7 -- 02.11.11 reworked url treatment
#version 1.7.8 -- 09.11.11 added --minimal
#version 1.7.9 -- 10.01.12 bumped latest to 1.2.2
#version 1.8.0 -- 29.01.12 add support for non-votca progs
#version 1.8.1 -- 02.02.12 make it work in bash 4.0 again
#version 1.8.2 -- 15.02.12 update to new googlecdoe url to avoid insec. certs
#version 1.8.3 -- 04.07.12 remove -DEXTERNAL_BOOST=OFF from --minimal
#version 1.8.4 -- 07.03.13 bumped gromacs version to 4.6.1
#version 1.8.5 -- 19.05.13 added ctp-tutorials
#version 1.8.6 -- 07.07.13 allow spaces in -D option (fixes issue 133)
#version 1.8.7 -- 08.10.13 fix git checkout of gromacs
#version 1.8.8 -- 19.10.13 allow mixing of options and programs
#version 1.8.9 -- 31.08.14 added --verbose option
#version 1.9.0 -- 02.09.14 added --builddir and --ninja
#version 1.9.1 -- 09.09.14 added --runtest option
#version 1.9.2 -- 28.12.14 added --gmx-release option and gmx 5.0 support
#version 1.9.3 -- 01.03.15 dropped support for espressopp
#version 1.9.4 -- 13.03.15 moved selfurl to github
#version 1.9.5 -- 20.03.15 added --use-git to support cloning from github
#version 1.9.6 -- 27.06.15 added --use-hg
#version 1.9.7 -- 23.08.15 make git the default vcs system
#version 2.0.0 -- 25.08.15 removed everything hg
#version 2.0.1 -- 09.09.15 added proxy workaround for git
#version 2.0.2 -- 23.09.15 dropped --dist-pristine 
#version 2.0.3 -- 23.09.15 bump gmx version
#version 2.0.4 -- 13.01.16 dropped --dist
#version 2.0.5 -- 25.05.16 dropped --cmake and --gui use $CMAKE instead
#version 2.0.6 -- 17.07.16 bumped gromacs version to 5.1.2

#defaults
usage="Usage: ${0##*/} [options] [progs]"
prefix="$HOME/votca"

#this gets overriden by --dev option
all_progs="tools csg csg-tutorials csgapps csg-testsuite csg-manual gromacs"
#programs to build by default
standard_progs="tools csg"

if [[ -f /proc/cpuinfo ]]; then #linux
  j="$(grep -c processor /proc/cpuinfo 2>/dev/null)" || j=0
elif [[ -x /usr/sbin/sysctl ]]; then #mac os
  j="$(/usr/sbin/sysctl -n hw.ncpu 2>/dev/null)" || j=0
elif [[ -x /usr/sbin/lsdev ]]; then #AIX
  j=$(/usr/sbin/lsdev 2>/dev/null | sed -n '/Processor/p' | sed -n '$=')
else
  j=0
fi
((j++))

do_prefix_clean="no"
do_clean_ignored="no"

do_build="yes"
do_cmake="yes"
do_clean="yes"
do_install="yes"

do_update="no"
do_devdoc="no"
do_manual="no"
dev="no"
wait=
verbose=
tests=()
git_depth=

changelogcheck="yes"
branchcheck="yes"
distcheck="yes"
relcheck="yes"
progcheck="yes"
progs=()

self_download="no"
cmake="${CMAKE:=cmake}"
cmake_builddir="."

rel=""
selfurl="https://raw.githubusercontent.com/votca/buildutil/master/build.sh"
clurl="https://raw.githubusercontent.com/votca/csg/stable/CHANGELOG.md"
gromacs_ver="5.1.2"

rpath_opt="-DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON"
cmake_opts=()

GIT="${GIT:=git}"
WGET="${WGET:=wget}"

BLUE="[34;01m"
CYAN="[36;01m"
CYANN="[36m"
GREEN="[32;01m"
RED="[31;01m"
PURP="[35;01m"
OFF="[0m"

die () {
  [[ -n $1 ]] && cecho RED "$*" >&2
  exit 1
}

is_in() {
  [[ -z $1 || -z $2 ]] && die "${FUNCNAME}: Missing argument"
  [[ " ${@:2} " = *" $1 "* ]]
}

cecho() {
  local colors="BLUE CYAN CYANN GREEN RED PURP"
  [[ -z $1 || -z $2 ]] && die "${FUNCNAME}: Missing argument"
  is_in "$1" "$colors" || die "${FUNCNAME}: Unknown color '$1' ($colors allowed)"
  echo -n "${!1}"
  echo -e "${@:2}""${OFF}"
}

build_devdoc() {
  local ver
  cecho GREEN "Building devdoc"
  [[ -z $(type -p doxygen) ]] && die "doxygen not found"
  [[ -f tools/share/doc/Doxyfile.in ]] || die "Could not get Doxyfile.in from tools repo"
  ver=$(get_votca_version tools/CMakeLists.txt) || die
  sed -e '/^PROJECT_NAME /s/=.*$/= Votca/' \
      -e '/^PROJECT_NUMBER /s/=.*$/= '"$ver/" \
      -e '/^INPUT /s/=.*$/= '"${progs[*]/gromacs}/" \
      -e '/^HTML_FOOTER /s/=.*$/= footer.html/' \
      -e '/^HTML_OUTPUT /s/=.*$/= devdoc/' \
      tools/share/doc/Doxyfile.in > Doxyfile || die "Making of Doxyfile failed"
  : > footer.html
  doxygen || die "Doxygen failed"
  rm -f Doxyfile footer.html
}

prefix_clean() {
  local i files=()
  cecho GREEN "Starting clean out of prefix"
  for i in ${prefix}/{bin,include,lib{,32,64},share}; do
    [[ -d $i ]] && files+=( "$i" )
  done
  if [[ ${#files[@]} -eq 0 ]]; then
    cecho BLUE "Found nothing to clean"
    return
  fi
  echo "I will $(cecho RED remove): ${files[@]#${prefix}/}"
  countdown 10
  rm -rf "${files[@]}"
  cecho GREEN "Done, hope you are happy now"
}

countdown() {
  [[ -z $1 ]] && "countdown: Missing argument"
  [[ -n ${1//[0-9]} ]] && "countdown: argument should be a number"
  [[ $wait = "no" ]] && return
  cecho RED -n "(CTRL-C to stop) "
  for ((i=$1;i>0;i--)); do
    cecho CYANN -n "$i "
    sleep 1
  done
  echo
}

download_and_upack_tarball() {
  local url tarball tardir
  [[ -z $1 || -z $2 ]] && die "${FUNCNAME}: Missing argument"
  url="$1"
  tarball="$2"
  cecho GREEN "Download tarball $tarball from ${url}"
  if [ "$self_download" = "no" ]; then
    [ -f "$tarball" ] && die "Tarball $tarball is already there, remove it first or add --selfdownload option"
    [ -z "$(type -p "${WGET}")" ] && die "${WGET} is missing"
    "${WGET}" "${url}"
  fi
  [ -f "${tarball}" ] || die "${WGET} has failed to fetch the tarball (add --selfdownload option and copy ${tarball} in ${PWD} by hand)"
  tardir="$(tar -tzf "${tarball}" | sed -e's#/.*$##' | sort -u)"
  [ -z "${tardir//*\\n*}" ] && die "Tarball $tarball contains zero or more then one directory ($tardir), please check by hand"
  [ -e "${tardir}" ] && die "Tarball unpack directory ${tardir} is already there, remove it first"
  tar -xzf "${tarball}"
  [[ $tardir = "$prog" ]] || mv "${tardir}" "${prog}"
  rm -f "${tarball}"
}

get_version() {
  sed -ne 's/^#version[[:space:]]*\([^[:space:]]*\)[[:space:]]*-- .*$/\1/p' "${1:--}" | sed -n '$p'
}

get_webversion() {
  local version
  if [[ $1 = "-q" ]]; then
    version="$("${WGET}" -qO- "${selfurl}" | get_version)"
  else
    [[ -z $(type -p "${WGET}") ]] && die "${WGET} not found"
    version="$("${WGET}" -qO- "${selfurl}" )" || die "${FUNCNAME}: ${WGET} fetch from $selfurl failed"
    version="$(echo -e "${version}" | get_version)"
    [[ -z ${version} ]] && die "${FUNCNAME}: Could not fetch new version number"
  fi
  echo "${version}"
}

get_votca_version() {
  local ver
  [[ -z $1 ]] && die "${FUNCNAME}: Missing argument"
  [[ -f $1 ]] || die "${FUNCNAME}: Could not find '$1'"
  ver="$(sed -n 's@^.*(PROJECT_VERSION "\([^"]*\)").*$@\1@p' "$1")" || die "Could not grep PROJECT_VERSION from '$1'"
  [[ -z ${ver} ]] && die "PROJECT_VERSION is empty"
  echo "$ver"
}

get_url() {
  local url
  [[ -z $1 || -z $2  ]] && die "${FUNCNAME}: Missing argument"
  if [[ $1 = source ]]; then
    case $2 in
      tools|csg*|moo|kmc|ctp*|xtp*)
	[[ -n $http_proxy || -n $https_proxy ]] && \
        echo "https://github.com/votca/$2" || \
        echo "git://github.com/votca/$2";;
      gromacs)
	[[ -n $http_proxy || -n $https_proxy ]] && \
	echo "https://gerrit.gromacs.org/gromacs.git" || \
	echo "git://git.gromacs.org/gromacs";;
    esac
  elif [[ $1 = release ]]; then
    case $2 in
      *testsuite)
	true;;
      tools|csg*|moo|kmc|ctp*|*manual)
	[[ -z $rel ]] && die "${FUNCNAME}: rel variable not set"
	[[ $rel = 1.[012]* ]] && 
	echo "https://github.com/votca/downloads/raw/master/votca-${2}-${rel}.tar.gz" || \
	echo "https://github.com/votca/${2}/archive/v${rel}.tar.gz";;
      gromacs)
	[[ -z $gromacs_ver ]] && die "${FUNCNAME}: gromacs_ver variable not set"
	echo "ftp://ftp.gromacs.org/pub/gromacs/gromacs-${gromacs_ver}.tar.gz"
    esac
  else
    die "${FUNCNAME}: unknown type $1"
  fi
}

make_or_ninja() {
  [[ -f Makefile && -f build.ninja ]] && die "$prog is configured to use Ninja and make, which won't work, add --clean-ignored to the command line once"
  if [[ -f Makefile ]]; then
    make -j${j} ${verbose:+VERBOSE=1} "$@"
  elif [[ -f build.ninja ]]; then
    ninja -j${j} ${verbose:+-v} "$@"
  else
    cecho BLUE "Neither Makefile nor build.ninja found, skipping"
  fi
}

version_check() {
  old_version="$(get_version "${self}")"
  [ "$1" = "-q" ] && new_version="$(get_webversion -q)" || new_version="$(get_webversion)"
  [ "$1" = "-q" ] || cecho BLUE "Version of $selfurl is: $new_version"
  [ "$1" = "-q" ] || cecho BLUE "Local Version: $old_version"
  [[ "${old_version}" < "${new_version}" ]]
  return $?
}

self_update() {
  [[ -z $(type -p "${WGET}") ]] && die "${WGET} not found"
  if version_check; then
    cecho RED "I will try replace myself now with $selfurl"
    countdown 5
    "${WGET}" -O "${self}" "${selfurl}"
  else
    cecho GREEN "No updated needed"
  fi
}

show_help () {
  cat << eof
    This is the votca build utils which builds votca modules
    Give multiple programs to build them. Nothing means: $standard_progs
    One can build: $all_progs

    Please visit: $(cecho BLUE www.votca.org)

    The normal sequence of a build is:
    - git clone (if src is not there)
      and checkout stable branch unless --dev given
      (or downloads tarballs if --release given)
    - git pull --ff-only (if --do-update given)
    - run cmake (unless --no-cmake)
    - make clean (unless --no-clean given)
    - make (unless --no-build given)
    - make install (disable with --no-install)

ADV The most recent version can be found at:
ADV $(cecho BLUE $selfurl)
ADV
    $usage

    OPTIONS (last overwrites previous one):
    $(cecho GREEN -h), $(cecho GREEN --help)              Show a short help
        $(cecho GREEN --longhelp)          Show a detailed help
ADV $(cecho GREEN -v), $(cecho GREEN --version)           Show version
ADV     $(cecho GREEN --debug)             Enable debug mode
ADV     $(cecho GREEN --log) $(cecho CYAN FILE)          Generate a file with all build infomation
ADV     $(cecho GREEN --nocolor)           Disable color
ADV     $(cecho GREEN --selfupdate)        Do a self update
ADV $(cecho GREEN -d), $(cecho GREEN --dev)               Switch to developer mode
ADV     $(cecho GREEN --release) $(cecho CYAN REL)       Get Release tarball instead of using git clone
ADV     $(cecho GREEN --gmx-release) $(cecho CYAN REL)   Use custom gromacs release
ADV                         Default: $gromacs_ver
    $(cecho GREEN -l), $(cecho GREEN --latest)            Get the latest tarball
    $(cecho GREEN -u), $(cecho GREEN --do-update)         Do an update of the sources using git
ADV $(cecho GREEN -U), $(cecho GREEN --just-update)       Just update the source and do nothing else
ADV $(cecho GREEN -c), $(cecho GREEN --clean-out)         Clean out the prefix (DANGEROUS)
ADV   $(cecho GREEN --clean-ignored)       Remove ignored file from repository (SUPER DANGEROUS)
ADV     $(cecho GREEN --no-cmake)          Do not run cmake
ADV $(cecho GREEN -D)$(cecho CYAN '*')                     Extra cmake options (maybe multiple times)
ADV                         Do NOT put variables (XXX=YYY) here, just use environment variables
ADV     $(cecho GREEN --minimal)           Build with minimum deps
ADV                         $(cecho GREEN -D)$(cecho CYAN WITH_FFTW=OFF) $(cecho GREEN -D)$(cecho CYAN WITH_GSL=OFF) $(cecho GREEN -D)$(cecho CYAN WITH_MKL=OFF) $(cecho GREEN -D)$(cecho CYAN BUILD_MANPAGES=OFF) $(cecho GREEN -D)$(cecho CYAN WITH_GMX=OFF) $(cecho GREEN -D)$(cecho CYAN WITH_H5MD=OFF))
ADV                         Functionality, which is really needed can explicitly be enabled again with $(cecho GREEN -D)$(cecho CYAN XXX=)$(cecho BLUE ON)
ADV $(cecho GREEN -R), $(cecho GREEN --no-rpath)          Remove rpath from the binaries (cmake default)
ADV     $(cecho GREEN --no-clean)          Don't run make clean
ADV $(cecho GREEN -j), $(cecho GREEN --jobs) $(cecho CYAN N)            Allow N jobs at once for make
ADV                         Default: $j (auto)
ADV     $(cecho GREEN --verbose)           Run make/ninja in verbose mode
ADV $(cecho GREEN -C), $(cecho GREEN --directory) $(cecho CYAN DIR)     Change into $(cecho CYAN DIR) before doing anything
ADV     $(cecho GREEN --no-build)          Don't build the source
ADV $(cecho GREEN -W), $(cecho GREEN --no-wait)           Do not wait, at critical points (DANGEROUS)
ADV     $(cecho GREEN --no-install)        Don't run make install
ADV     $(cecho GREEN --runtest) $(cecho CYAN DIR)       Run one step $(cecho CYAN DIR) as a test, when csg-tutorials is build (EXPERIMENTAL)
ADV                         Use CSG_MDRUN_STEPS environment variable to control the number of steps to run.
ADV     $(cecho GREEN --warn-to-errors)    Turn all warnings into errors (same as  $(cecho GREEN -D)$(cecho CYAN CMAKE_CXX_FLAGS=\'-Wall -Werror\'))
ADV     $(cecho GREEN --Wall)              Show more warnings (same as $(cecho GREEN -D)$(cecho CYAN CMAKE_CXX_FLAGS=-Wall))
ADV     $(cecho GREEN --devdoc)            Build a combined html doxygen for all programs (useful with $(cecho GREEN -U))
ADV     $(cecho GREEN --build-manual)      Build a manual inside programs if available
ADV     $(cecho GREEN --ninja)             Use ninja instead of make
ADV                         Default: cmake's default (make)
ADV     $(cecho GREEN --depth) $(cecho CYAN D)           Only git clone to depth $(cecho CYAN D) instead of whole history
ADV     $(cecho GREEN --builddir) $(cecho CYAN DIR)      Do an out-of-source build in $(cecho CYAN DIR)
ADV                         Default: $cmake_builddir
    $(cecho GREEN -p), $(cecho GREEN --prefix) $(cecho CYAN PREFIX)     Use install prefix $(cecho CYAN PREFIX)
                            Default: $prefix

    Examples:  ${0##*/} tools csg
               ${0##*/} -dcu --prefix=\$PWD/install tools csg
               ${0##*/} -u
               ${0##*/} --release ${latest} tools csg
               ${0##*/} --dev --longhelp
               CC=g++ ${0##*/} -DWITH_GMX=OFF csg

eof
}

[[ ${0} = /* ]] && self="${0}" || self="${PWD}/${0}" || self="${0}" 
#save before parsing for --log
cmdopts=( "$@" )
# parse arguments
shopt -s extglob
while [[ $# -gt 0 ]]; do
  if [[ ${1} = --*=* ]]; then # case --xx=yy
    set -- "${1%%=*}" "${1#*=}" "${@:2}" # --xx=yy to --xx yy
  elif [[ ${1} = -[^-]?* ]]; then # case -xy split
    if [[ ${1} = -[jpD]* ]]; then #short opts with arguments
       set -- "${1:0:2}" "${1:2}" "${@:2}" # -xy to -x y
    else #short opts without arguments
       set -- "${1:0:2}" "-${1:2}" "${@:2}" # -xy to -x -y
    fi
 fi
 case $1 in
   --debug)
    set -x
    shift ;;
   --log)
    [ -n "$2" ] || die "Missing argument after --log"
    if [[ -z ${VOTCA_LOG} ]]; then
      echo "Logfile is $(cecho PURP "$2")"
      export VOTCA_LOG="$2"
      echo "Log of '${self} ${cmdopts[@]// /\\ }'" > "$2"
      "${self}" "${cmdopts[@]}" | tee -a "$2"
      exit $?
    fi
    shift 2;;
   -h | --help)
    show_help | sed -e '/^ADV/d' -e 's/^    //'
    exit 0;;
  --longhelp)
   show_help | sed -e 's/^ADV/   /' -e 's/^    //'
   exit 0;;
   -v | --version)
    echo "${0##*/}, version $(get_version "${self}")"
    exit 0;;
   --git)
    sed -ne 's/^#version[[:space:]]*\([^[:space:]]*\)[[:space:]]*-- [0-9][0-9]\.[0-9][0-9]\.[0-9][0-9] \(.*\)$/\2/p' "${self}" | sed -n '$p'
    exit 0;;
   --selfupdate)
    self_update
    exit $?;;
   -c | --clean-out)
    do_prefix_clean="yes"
    shift 1;;
   --clean-ignored)
    do_clean_ignored="yes"
    shift 1;;
   -j | --jobs)
    [[ -z $2 ]] && die "Missing argument after --jobs"
    [[ -n ${2//[0-9]} ]] && die "Argument after --jobs should be a number"
    j="$2"
    shift 2;;
   --verbose)
     verbose=yes
     shift 1;;
   -C | --directory)
     [[ -z $2 ]] && die "Missing argument after --directory"
     cd "$2" || die "Could not change into directory '$2'"
     shift 2;;
   --no-build)
    do_build="no"
    shift 1;;
   -u | --do-update)
    do_update="yes"
    shift 1;;
   -U | --just-update)
    do_update="only"
    shift 1;;
   --builddir)
     [[ -z $2 ]] && die "Missing argument after --builddir"
     cmake_builddir="$2"
     shift 2;;
   --ninja)
     cmake_opts+=( -G Ninja )
     shift 1;;
   --depth)
     [[ -z $2 ]] && die "Missing argument after --depth"
     [[ -n ${2//[0-9]} ]] && die "Argument after --depth should be a number"
     git_depth="$2"
     shift 2;;
   --Wall)
    cmake_opts+=( -DCMAKE_CXX_FLAGS='-Wall' )
    shift ;;
   --warn-to-errors)
    cmake_opts+=( -DCMAKE_CXX_FLAGS='-Wall -Werror' )
    shift ;;
   -R | --no-rpath)
    rpath_opt=""
    shift 1;;
   --runtest)
    [[ -z $2 ]] && die "Missing argument after --runtests"
    tests+=( "$2" )
    shift 2;;
   --devdoc)
    do_devdoc="yes"
    shift 1;;
   --build-manual)
    do_manual="yes"
    shift 1;;
  --no-@(build|clean|cmake|install))
    eval do_"${1#--no-}"="no"
    shift 1;;
   -W | --no-wait)
    wait="no"
    shift 1;;
  --no-@(branch|changelog|dist|prog|rel)check)
    eval "${1#--no-}"="no"
    shift 1;;
   --selfdownload)
    self_download="yes"
    shift 1;;
   -p | --prefix)
    prefix="$2"
    shift 2;;
  -D)
    [[ -z $2 ]] && die "Missing argument after --D"
    cmake_opts+=( -D"${2}" )
    shift 2;;
  --minimal)
    cmake_opts+=( --no-warn-unused-cli -DWITH_FFTW=OFF -DWITH_GSL=OFF -DWITH_MKL=OFF -DBUILD_MANPAGES=OFF -DWITH_GMX=OFF -DWITH_SQLITE3=OFF -DWITH_H5MD=OFF )
    shift;;
   --release)
    rel="$2"
    [[ $relcheck = "yes" && ${rel} != [1-9].[0-9]?(.[1-9]|_rc[1-9]) ]] && \
      die "--release option needs an argument which is a release (disable this check with --no-relcheck option)"
    shift 2;;
   --gmx-release)
    gromacs_ver="$2"
    [[ $relcheck = "yes" && ${2} != [1-9]*([0-9])?(.[0-9])?(.[1-9]|-rc[1-9]) ]] && \
      die "--gmx-release option needs an argument which is a release (disable this check with --no-relcheck option)"
    shift 2;;
   -l | --latest)
    [[ -z $(type -p "${WGET}") ]] && die "${WGET} not found, specify it by hand using --release option"
    rel=$("${WGET}" -O - -q "${clurl}" | \
      sed -n 's/^## Version \([^ ]*\) .*/\1/p' | \
      sed -n '1p')
    [[ -z $rel || ${rel} != [1-9].[0-9]?(.[1-9]|_rc[1-9]) ]] && \
      die "${WGET} could not get the version (found $rel), specify it by hand using --release option"
    shift;;
   --nocolor)
    unset BLUE CYAN CYANN GREEN OFF RED PURP
    shift;;
   -d | --dev)
    dev=yes
    all_progs="${all_progs} moo kmc ctp ctp-manual ctp-tutorials xtp"
    shift 1;;
  -*)
   die "Unknown option '$1'"
   exit 1;;
  *)
   [[ -n $1 ]] && progs+=( "$1" )
   shift 1;;
 esac
done

if version_check -q; then
  x=${0##*/}; x=${x//?/#}
  cecho RED "########################################$x"
  cecho RED "# Your version of VOTCA ${0##*/} is obsolete ! #"
  cecho RED "# Please run '${0##*/} --selfupdate'           #"
  cecho RED "########################################$x"
  die
  unset x
fi

[[ ${#progs[@]} -eq 0 ]] && progs=( $standard_progs )
[[ -z $prefix ]] && die "Error: prefix is empty"
[[ $prefix = *WHERE/TO/INSTALL/VOTCA* ]] && die "Deine Mutti!!!\nGo and read the instruction again."
[[ $prefix = /* ]] || die "prefix has to be a global path (should start with a '/')"

#infos
cecho GREEN "This is VOTCA ${0##*/}, version $(get_version "${self}")"
echo "Install prefix is '$prefix'"
[[ -n $CPPFLAGS ]] && echo "CPPFLAGS is '$CPPFLAGS'"
[[ -n $CXXFLAGS ]] && echo "CXXFLAGS is '$CXXFLAGS'"
[[ -n $LDFLAGS ]] && echo "LDFLAGS is '$LDFLAGS'"
cecho BLUE "Using $j jobs for make/ninja"

[[ $do_prefix_clean = "yes" ]] && prefix_clean

set -e
for prog in "${progs[@]}"; do
  [[ ${progcheck} = "yes" ]] && ! is_in "${prog}" "${all_progs}" && \
    die "Unknown progamm '$prog', I know: $all_progs (disable this check with --no-progcheck option)"

  #sets pkg-config dir to make csg find tools
  #adds libdir to (DY)LD_LIBRARY_PATH to allow runing csg_* for the manual
  #set path to find csg_* for the manual
  if [[ -f "$prefix/bin/VOTCARC.bash" ]]; then
    cecho BLUE "sourcing '$prefix/bin/VOTCARC.bash'"
    source "$prefix/bin/VOTCARC.bash" || die "sourcing of '$prefix/bin/VOTCARC.bash' failed"
  fi

  cecho GREEN "Working on $prog"
  if [[ -d $prog && -z $rel ]]; then
    cecho BLUE "Source dir ($prog) is already there - skipping checkout"
  elif [[ -d $prog && -n $rel ]]; then
    cecho BLUE "Source dir ($prog) is already there - skipping download"
    countdown 5
  elif [[ -n $rel && -z $(get_url release $prog) ]]; then
    cecho BLUE "Program $prog has no release tarball I will get it from the its git repository"
    [[ -z $(get_url source $prog) ]] && die "but I don't know its source url - get it yourself and put it in $prog"
    [ -z "$(type -p "$GIT")" ] && die "Could not find $GIT, please install git (http://http://git-scm.com/)"
    countdown 5
    "$GIT" clone ${git_depth:+--no-single-branch --depth $git_depth} "$(get_url source "$prog")" "$prog"
  elif [[ -n $rel && -n $(get_url release "$prog") ]]; then
    download_and_upack_tarball "$(get_url release "$prog")" "votca-${prog}-${rel}.tar.gz"
  else
    [[ -z $(get_url source $prog) ]] && die "I don't know the source url of $prog - get it yourself and put it in dir $prog"
    cecho BLUE "Doing checkout for $prog from $(get_url source $prog)"
    countdown 5
    [[ -z "$(type -p "$GIT")" ]] && die "Could not find $GIT, please install git (http://http://git-scm.com/)"
    "$GIT" clone ${git_depth:+--no-single-branch --depth $git_depth} "$(get_url source $prog)" "$prog"
    pushd "$prog" > /dev/null || die "Could not change into $prog"
    if [[ $prog = gromacs ]]; then
      if [[ ${gromacs_ver} = [45].[0-9]* ]]; then
        gmx_branch="release-${gromacs_ver:0:1}-${gromacs_ver:2:1}" #e.g. release-5-1
      elif [[ ${gromacs_ver} = 201[6-9]* ]]; then
        gmx_branch="release-${gromacs_ver:0:4}" #e.g. release-2016
      elif [[ ${gromacs_ver} = 9999* ]]; then
        gmx_branch="master"
      else
        die "I don't on which branch gromacs version $gromacs_ver sits"
      fi
      "$GIT" checkout "${gmx_branch}"
    elif [[ ${dev} = "no" ]]; then
      if [[ -n $("$GIT" branch --list stable) || -n $("$GIT" branch -r --list origin/stable) ]]; then
        cecho BLUE "Switching to stable branch add --dev option to prevent that"
        "$GIT" checkout stable
      else
        cecho BLUE "No stable branch found, skipping switching!"
      fi
    fi
    popd > /dev/null || die "Could not change back"
  fi

  pushd "$prog" > /dev/null || die "Could not change into $prog"
  if [[ $do_update == "yes" || $do_update == "only" ]]; then
    if [ -n "$rel" ]; then
      cecho BLUE "Update of a release tarball doesn't make sense, skipping"
      countdown 5
    elif [[ -d .git ]]; then
      cecho GREEN "updating git repository $prog from $(git rev-parse --abbrev-ref @{u})"
      cecho GREEN "We are on branch $(cecho BLUE "$("$GIT" rev-parse --abbrev-ref HEAD)")"
      "$GIT" pull --ff-only
      if [[ ${TRAVIS} = true && ${TRAVIS_REPO_SLUG} = */${prog} ]]; then
        branchcheck=no #travis users hopefully know what they are doing
        if [[ ${TRAVIS_PULL_REQUEST} != false ]]; then
          cecho PURP "Checking out pull request ${TRAVIS_PULL_REQUEST} from git://github.com/${TRAVIS_REPO_SLUG}"
          git fetch "git://github.com/${TRAVIS_REPO_SLUG}" +refs/pull/"${TRAVIS_PULL_REQUEST}"/merge:
          git checkout FETCH_HEAD
        else
          cecho PURP "Checking out ${TRAVIS_COMMIT} of branch ${TRAVIS_BRANCH} from git://github.com/${TRAVIS_REPO_SLUG}"
	  #hopefully TRAVIS_COMMIT is within the last 10 commits
          git fetch --depth=10 "git://github.com/${TRAVIS_REPO_SLUG}" "${TRAVIS_BRANCH}"
          git checkout "${TRAVIS_COMMIT}"
        fi
      fi
    else
      cecho BLUE "$prog dir doesn't seem to be a git repository, skipping update"
      countdown 5
    fi
  fi
  if [[ $do_update == "only" ]]; then
    popd > /dev/null || die "Could not change back"
    continue
  fi
  if [[ -d .git && $branchcheck = "yes" ]]; then
    if [[ $prog = gromacs ]]; then
      [[ ${TRAVIS} != true && $("$GIT" rev-parse --abbrev-ref HEAD) != release-[0-9]* ]] && \
        die "We only support release branches in gromacs! Please checkout one of these, preferably the >5.0 release with: 'git -C gromacs checkout release-5-0' (disable this check with the --no-branchcheck option)"
    else
      [[ -z $branch ]] && branch="$("$GIT" rev-parse --abbrev-ref HEAD)"
      [[ $dev = "no" ]] && [[ -n $($GIT branch --list stable) || -n $("$GIT" branch -r --list origin/stable) ]] && [[ $($GIT rev-parse --abbrev-ref HEAD) != "stable" ]] && \
        die "We build the stable version of $prog, but we are on branch $($GIT rev-parse --abbrev-ref HEAD) and not 'stable'. Please checkout the stable branch with 'git -C $prog checkout stable' or add --dev option (disable this check with the --no-branchcheck option)"
      [[ $dev = "yes" && $("$GIT" rev-parse --abbrev-ref HEAD) = "stable" ]] && \
	die "We build the devel version of $prog, but we are on the stable branch. Please checkout a devel branch like default with 'git -C $prog checkout master' (disable this check with the --no-branchcheck option)"
      #prevent to build devel csg with stable tools and so on
      [[ $branch != $("$GIT" rev-parse --abbrev-ref HEAD) ]] && die "You are mixing branches: '$branch' (in $last_prog) vs '$("$GIT" rev-parse --abbrev-ref HEAD) (in $prog)' (disable this check with the --no-branchcheck option)\nYou can change the branch with 'git -C $prog checkout BRANCHNAME'."
    fi
  fi
  if [ "$do_clean_ignored" = "yes" ]; then
    if [[ -d .git ]]; then
      cecho BLUE "I will remove all ignored files from $prog"
      countdown 5
      "$GIT" clean -fdX
    else
      cecho BLUE "$prog dir doesn't seem to be a git repository, skipping remove of ignored files"
      countdown 5
    fi
  fi
  if [ "$do_clean" == "yes" ]; then
    rm -f CMakeCache.txt
  fi
  cmake_srcdir="$PWD"
  if [[ -f CMakeLists.txt ]]; then
    [[ -z $(sed -n '/^project(.*)/p' CMakeLists.txt) ]] && die "The current directory ($PWD) does not look like a source main directory (no project line in CMakeLists.txt found)"
    [[ -d "$cmake_builddir" ]] || mkdir -p "$cmake_builddir" || die "Could not make dir '$cmake_builddir'"
    if [[ $(pwd -P) != $(cd $cmake_builddir; pwd -P) ]]; then #if out-of-source build
      [[ -d CMakeFiles ]] && die "$prog is already configured in-source, but we are trying to build out-of-source, add --clean-ignored to the command line once"
    else
      cmake_srcdir="."
    fi
    pushd "$cmake_builddir" > /dev/null || die "Could not change into '$cmake_builddir'"
  fi
  if [[ $do_cmake == "yes" && -f ${cmake_srcdir}/CMakeLists.txt ]]; then
    [[ -z $(type -p ${CMAKE}) ]] && die "Could not find ${CMAKE}"
    cecho BLUE "${CMAKE} -DCMAKE_INSTALL_PREFIX='$prefix' ${cmake_opts[@]// /\\ } $rpath_opt ${cmake_srcdir}"
    ${CMAKE} -DCMAKE_INSTALL_PREFIX="$prefix" "${cmake_opts[@]}" "$rpath_opt" "${cmake_srcdir}"
  fi
  if [[ $do_clean == "yes" ]]; then
    cecho GREEN "cleaning $prog"
    make_or_ninja clean
  fi
  if [[ $do_build == "yes" ]]; then
    cecho GREEN "buidling $prog"
    make_or_ninja
  fi
  if [[ "$do_install" == "yes" ]]; then
    cecho GREEN "installing $prog"
    make_or_ninja install
  fi
  if [[ -d manual && $do_manual = yes ]]; then
    cecho GREEN "buidling manual for $prog"
    make_or_ninja manual
    make_or_ninja installmanual
  fi
  if [[ -f $cmake_srcdir/CMakeLists.txt ]]; then
    popd > /dev/null || die "Could not change back"
  fi
  if [[ $prog = csg-tutorials ]]; then
    for t in "${tests[@]}"; do
      pushd $t  > /dev/null ||  die "Could not change into '$t'"
      [[ -f settings.xml ]] || die "Could not find settings.xml in '$t'"
      cecho GREEN "running one iteration of $t in ${prog}"
      [[ $do_clean != yes ]] || csg_inverse ${wait:+--nowait} --options settings.xml clean || die "'csg_inverse --options cg.xml clean' failed in '$t'"
      if ! CSG_RUNTEST=yes csg_inverse --options settings.xml --do-iterations 1; then
        sleep 1
        [[ -f inverse.log ]] && tail -200 inverse.log
	die "'csg_inverse --options settings.xml --do-iterations 1' failed in '$t'"
      fi
      popd > /dev/null
    done
  fi
  popd > /dev/null || die "Could not change back"
  cecho GREEN "done with $prog"
  last_prog="$prog"
done
set +x

[[ $do_devdoc = "no" ]] || build_devdoc
