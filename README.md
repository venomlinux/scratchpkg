# scratchpkg

A package manager for [Venom Linux](https://venomlinux.org/).

## Description

Scratchpkg is a package manager built in order to manage packages for Venom Linux. This package manager
is fully written in bash. The package building script uses the port system like in Arch's makepkg and CRUX's pkgmk. Packages are built and installed into a temporary location using DESTDIR method and are afterwards compressed in a file 
directory using tar.

Installing the packaged tar means it is extracted into real system. After that all files extracted is recorded into an index
directory. So scratchpkg will track all installed files. Scratchpkg can automatically resolve dependencies order. Scratchpkg
reads the build script (spkgbuild) in the ports directory in order to get all necessary variables and functions before building
them.

## spkgbuild

`spkgbuild` is build script sourced by `pkgbuild` to build the package.
The example of `spkgbuild` as follows:

    # description	: This is example package
    # homepage	: https://example.com/
    # maintainer	: Emmett1, emmett1 dot 2miligrams at gmail dot com
    # depends	: package1 package2 package3

    name=foobar
    version=1.0.0
    release=1
    backup=(etc/example.conf etc/foobar.conf)
    noextract=(foobar.tar.xz)
    options=(!strip libtool)
    source=(https://dl.example.com/foobar.tar.xz
            $name-$version.tar.gz::https://github.com/achieve/$version.tar.gz
            example.conf)
    nostrip=(lib.*/ld-.*\.so$
            lib.*/libc-.*\.so$
            lib.*/libpthread-.*\.so$
            lib.*/libthread_db-.*\.so$)
	
    build() {
        cd $name-$version
      
        ./configure --prefix=/usr
        make
        make DESTDIR=$PKG install
      
        install -d $SRC/example.conf $PKG/etc/example.conf
    }
    
*Note: When create new package, its recommended to build using fakeroot first to make sure the build script is not broken and leave untracked file inside system.*

#### spkgbuild format:

* `description`: Short description for package.
* `homepage`: Url for software webpage
* `maintainer`: maintainer name and email
* `depends`: All required dependencies, separate with space.
* `name`: Package name, need same as port directory's name.
* `version`: Package's version.
* `release`: Package's release version, useful when build script need change with same package version.
* `options`: Package's build options, see 'Package options' for available options.
* `backup`: File need backup when upgrading package (without leading with '/').
* `noextract`: Specify file no need to extract, separate with space.
* `nostrip`: list file to avoid strip, can use regex
* `source`: Package's source urls, separate with space, can use as `<new-source-name>::<source-url>` to save source file with different name (see `spkgbuild` example).
    
## Package options
  
This options is set in `/etc/scratchpkg.conf` for global options:

  `OPTIONS=()`
  
For per package, set options in package's spkgbuild:

  `options=()`

Add `!` in front of options to disable it, example for disable strip and remove empty directory in package (per package) as follows:

`options=(!strip !emptydirs)`
    
Available options:

    libtool:     Keep libtool file (*.la) in packages.
    emptydirs:   Keep empty directories in packages.
    strip:       Strip symbols from binaries/libraries.
    zipman:      Compress manual (man and info) pages with gzip.
    buildflags:  Enable buildflags (CFLAGS and CXXFLAGS).
    makeflags:   Enable makeflags (MAKEFLAGS).
                                        
### pkgbuild
`pkgbuild` is a tool to build package from ports. Is will source `spkgbuild` to get build information before creating package. Package is created into `<name>-<version>-<release>.spkg.txz` format. To build package, you need `cd` into port directory before run `pkgbuild` command.

    Usage:
      pkgbuild [ <options> <arguments> ]

    Options:
      -i, --install             install package into system
      -u, --upgrade             upgrade package
      -r, --reinstall           reinstall package
      -c, --ignore-conflict     ignore conflict when installing package
      -v, --verbose             verbose install process
      -f, --force-rebuild       rebuild package
      -m, --skip-mdsum          skip md5sum checking
      -g, --genmdsum            generate md5sum
      -o, --download            download only source file
      -x, --extract             extract only source file
      -w, --keep-work           keep working directory
      -l, --log                 log build process
      -h, --help                show this help message
          --config=<config>     use custom config file
          --srcdir=<path>       override directory path for sources
          --pkgdir=<path>       override directory path for compiled package
          --logdir=<path>       override directory path for build logs
          --workdir=<path>      override directory path for working dir
          --no-preinstall       skip preinstall script before install package
          --no-postinstall      skip postinstall script after install package
          --no-preupgrade       skip preupgrade script before upgrade package
          --no-postupgrade      skip postupgrade script after upgrade package
          --no-backup           skip backup configuration file when upgrading package
          --redownload          re-download source file

    Example:
      pkgbuild -iw	        this will build, install package and keep working directory

    Note:
      * use pkgbuild without any options will only download source and build package by using other default options
      * pkgbuild need run inside port directory

      
### pkgadd
`pkgadd` is a tool to install and upgrade package created by `pkgbuild`. Install package is simply extract
`<name>-<version>-<release>.spkg.txz` by using tar into real system then save list extracted file into package `INDEX_DIR`.
Upgrading package is also using same extract as install, it will replace old files then compare list file from old and new
package and remove old file which not exist in new package (like Slackware pkgtool does).

    Usage:
      pkgadd package.spkg.txz <options>

    Options:
      -u, --upgrade              upgrade package
      -r, --reinstall            reinstall package
      -c, --ignore-conflict      ignore conflict when installing package
      -v, --verbose              print files installed
      -h, --help                 show this help message
          --no-preinstall        skip preinstall script before build/install package
          --no-postinstall       skip postinstall script after install package
          --no-preupgrade        skip preupgrade script before upgrade package
          --no-postupgrade       skip postupgrade script after upgrade package
          --no-backup            skip backup when upgrading package
	  --root=<path>          install to custom root directory

    Example:
      pkgadd foobar-1.0-1.spkg.txz -uc --no-backup       upgrade package foobar-1.0-1 without backup its 
                                                         old configuration files and skip conflict check
                                                             
### pkgdel
`pkgdel` is a tool to remove package from system. It will read file listed in package `INDEX_DIR` and remove it.

    Usage:
      pkgdel [ <options> <package name> ]

    Options:
      -h, --help            show this help message
      -v, --verbose         print removed files
          --no-preremove    don't run pre-remove script
          --no-postremove   don't run post-remove script
          --root=<path>     remove package from custom root directory

    Example:
      pkgdel firefox -v --no-preremove       remove package firefox, print deleted files and skip pre-remove script

### scratch
`scratch` is front-end for pkgbuild, pkgadd and pkgdel. Its changed directory in ports and call pkgbuild to build package, then
pkgadd to install package into system. Its also has some extra functions like search packages, check dependency, dependent,
orphan package, duplicate ports, list installed package and etc. Run `scratch help` to see available functions.

    Usage:
    scratch [ mode ] [ <pkgname> <options> ]	

    mode:
        install   <packages>      install packages and its dependencies
        upgrade   <packages>      upgrade packages and install new dependencies (if any)
        build     <package>       build only packages
        remove    <packages>      remove packages in system
        depends   <package>       show depends of a package
        deplist   <packages>      show list dependencies of a package
        search    <pattern>       search packages in port's repos
        lock      <packages>      lock packages from upgrade
        unlock    <packages>      unlock packages from upgrade
        listport  <repo>          list ports of a repo
        cat       <package>       view a package build scripts
        dependent <package>       show package's dependent
        own       <file>          show package's owner of file
        pkgtree   <package>       show list files of installed package
        path      <package>       show package's buildscripts path
        sync                      update port's repo
        sysup                     full system update
        dup                       print duplicate ports in repo
        readme                    print readme file if exist
        listinst                  list installed package in system
        listorphan                list orphan package
        integrity                 check integrity of package's files
        outdate                   check for outdate packages
        cache                     print leftover cache
        rmcache                   remove leftover cache
        missingdep                check for mising dependency of installed package
        foreignpkg                print package installed without port in repo
        listlocked                print locked packages
        help                      print this help message
	
    options for:		
        build
            -f, --force-rebuild    force rebuild
            -m, --skip-mdsum       skip md5sum check for sources
            -d, --no-dep           skip dependency check
            -e, --extract          extract only
            -w, --keep-work        keep woring directory
            -o, --download         download source files only
            --redownload           re-download source files
            --srcdir=<path>        override default SOURCE_DIR
            --pkgdir=<path>        override default PACKAGE_DIR
            --no-preinstall        skip pre-install script
        
        install
            -d, --no-dep           skip installing dependencies
            -c, --ignore-conflict  skip file conflict check
            -r, --reinstall        reinstall installed package
            -v, --verbose          print install process
            --no-preinstall        skip pre-install script
            --no-postinstall       skip post-install script
		
        upgrade
            -d, --no-dep           skip installing dependencies (new dependencies)
            -c, --ignore-conflict  skip file conflict check
            -v, --verbose          print install process
            --no-backup            skip backup configuration file
            --no-preupgrade        skip pre-upgrade script
            --no-postupgrade       skip post-upgrade script
		
        remove
            -d, --no-dep           skip dependency check
            -v, --verbose          print removed files
            --no-preremove         skip pre-remove script
            --no-postremove        skip post-remove script
		
    global options:
            --no-color             disable colour for output
            --debug                debug scratch script
      
    Example:
      scratch install firefox gvfs -cv     build and install required dependencies and target package itself,
                                           ignore file conflict check and be verbose.

      scratch remove firefox gvfs -dv      remove package firefox and gvfs from system, ignore dependent check
                                           and be verbose

## Extra tools
Extra tools is some scripts come with scratchpkg to help users do things more easier. More extra scripts may added from time to
time.

* `vchroot`: Chroot script.
* `pkglibdepends`: Script to list package depends by shared libraries.
* `portcreate`: Script to create template port.
* `updateconf`: Script to update configuration files (*.spkgnew).
* `revdep`: A reverse dependency script (like in Gentoo and CRUX, but my version), need to run after upgrade and remove package to check broken package(s). Specify package name if want to check single package only.
                                                             
## Install script

Install scripts is a bash script contains command need to run before/after install/upgrade/remove packages in system. The suffix
of install script is `install`. This install script need to placed in port directory and later will included in tar-ed
package. The script contains the following functions which run at different times:

This script is executed using `sh`. Argument is passed when this script is executed.

### install:
    $1 : pre-install/post-install
    $2 : version
    
### upgrade:
    $1 : pre-upgrade/post-upgrade
    $2 : version
    $3 : old version
    
### remove:
    $1 : pre-remove/post-remove
    $2 : old version

Example of install script for `dbus`:

    # package install script

    action=$1
    newversion=$2
    oldversion=$3

    case $action in
            pre-install)
                    getent group messagebus >/dev/null || groupadd -g 18 messagebus
                    getent passwd messagebus >/dev/null || useradd -c "D-Bus Message Daemon User" -d /var/run/dbus -u 18 -g messagebus -s /bin/false messagebus
                    ;;
            post-install)
                    dbus-uuidgen --ensure
                    ;;
    esac

## /etc/scratchpkg.repo

`/etc/scratchpkg.repo` is file to define repo directory and url to sync/update port's. This is example default
`/etc/scratchpkg.repo`;

    #
    # /etc/scratchpkg.repo : scratchpkg repo file
    #
    # format:
    #    <repo directory> <repo url for sync>
    #

    /usr/ports/core  https://raw.githubusercontent.com/venomlinux/ports/master/core
    /usr/ports/xorg  https://raw.githubusercontent.com/venomlinux/ports/master/xorg
    /usr/ports/extra https://raw.githubusercontent.com/venomlinux/ports/master/extra
    /usr/ports/xfce4 https://raw.githubusercontent.com/venomlinux/ports/master/xfce4
    /usr/ports/kf5   https://raw.githubusercontent.com/venomlinux/ports/master/kf5
    /usr/ports/lxde  https://raw.githubusercontent.com/venomlinux/ports/master/lxde
    
*Note: url is optional. Add if need to sync it.*


## Install

Installing is performed by just simply execute/running the file INSTALL.sh:

`./INSTALL.sh`

If packaging, append DESTDIR=/tmp/path in front of your command:

`DESTDIR=/tmp/path ./INSTALL.sh`
