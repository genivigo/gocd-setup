# These are typical packages needed for our builds.
# Depending on your needs you can skip installing them...

[ $(id -u) -eq 0 ] || { echo "Please make sure you run as root for installation" ; exit 1 ; }

PACKAGES_RPM="
     SDL-devel
     asciidoc
     autoconf
     automake
     bc
     bison
     boost-devel
     boost-log
     boost-system
     boost-thread
     build-essential
     bzip2
     ccache
     chrpath
     cmake
     cpio
     cpp
     cron
     curl
     dbus-c++-devel
     dbus-devel
     diffstat
     diffutils
     docbook-xsl
     doxygen
     expat-devel
     file
     findutils
     flex
     fontconfig
     fuse-devel
     g++-multilib
     gawk
     gcc
     gcc-c++
     gcc-multilib
     git
     glibc-devel
     gnupg
     graphviz
     gzip
     intltool
     lib32ncurses5-dev
     lib32z1-dev
     libc6-dev-i386
     libgl1-mesa-dev
     liblz4-tool
     libncurses5-dev
     libtool
     libx11-dev
     libxml2-utils
     m4
     make
     maven
     patch
     perl
     perl-Data-Dumper
     perl-Text-ParseWords
     perl-Thread-Queue
     perl-bignum
     pkgconfig
     pulseaudio-libs-devel
     python
     python-crypto
     python-pip
     python-wand
     python3
     python3-crypto
     python3-wand
     qemu-system-x86
     rsync
     socat
     source-highlight
     sudo
     systemd-devel
     tar
     texinfo
     uml-utilities
     unzip
     vim-tiny
     wget
     which
     x11proto-core-dev
     xsltproc
     xterm
     xz
     zip
     zlib1g-dev
"

     #python3
     #python3-pexpect
     #python3-pip

# Debian/Ubuntu - these are constantly updated by a cronjob in
# the docker-based agent setup at least.
# Let's reuse the same single source for that package list!
PACKAGES_DEB=" $(cat common_build_dependencies) "

installer=
[ -x "$(which apt-get 2>/dev/null)" ] && installer=apt-get
[ -x "$(which yum 2>/dev/null)" ] && installer=yum
[ -x "$(which dnf 2>/dev/null)" ] && installer=dnf
[ -e /etc/debian-release ] && installer=apt-get

case $installer in
   apt-get)
      export DEBIAN_FRONTEND=noninteractive
      sudo $installer update
      sudo $installer install -y $PACKAGES_DEB
      ;;
   dnf|yum)
      sudo $installer install -y $PACKAGES_RPM
      ;;
   *)
      echo "Unsupported package type - fix script"
      exit 1
      ;;
esac

# Bugfix deb packages that have changed names
osrelease=/etc/os-release
fgrep -q Ubuntu $osrelease && fgrep -q 14.04 $osrelease && sudo apt-get install libsystemd-daemon-dev
fgrep -q Ubuntu $osrelease && fgrep -q 16.04 $osrelease && sudo apt-get install libsystemd-dev
# FIXME - not sure which version needs what here...
if fgrep -q Debian $osrelease ; then
  sudo apt-get install libsystemd-daemon-dev || {
    echo "Failed?  Not sure on systemd package name, but no problem - trying another:"
  sudo apt-get install libsystemd-dev
}
fi

