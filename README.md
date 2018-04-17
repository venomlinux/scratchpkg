# scratchpkg

A package manager for Linux From Scratch.

## Description

Scratchpkg is a package manager built in order to manage packages for the Linux From Scratch system/distro. This package manager is fully written in bash. The package building script uses the port system like in Arch's makepkg, CRUX's pkgmk and NuTyX's cards. Packages are built and installed into a temporary location using DESTDIR method and are afterwards compressed in a file  directory using tar.

Installing the packaged tar means it is extracted into real system. After that all files are extracted into an index directory. So scratchpkg will track all installed files. Scratchpkg doesn't calculate dependency order but it does install missing dependency automatically. Let say you wanna install package foobar, when scratchpkg trying to install package foobar it will check for missing dependency, if the dependency is not installed, it will install foobar's dependency first before installing foobar.

Scratchpkg reads the build script (spkgbuild) in the ports directory in order to get all necessary variables and functions before building them. Full package information  like version, description, depends etc ... will be written into the package. So the built package isn't needing its port anymore for getting the necessary information. This is really an advantage supposing you would like to check for package dependencies or install a package that was built for another machine.

## spkgbuild

`spkgbuild` is build script sourced by `buildpkg` to build the package.
The example of `spkgbuild` as follows:

    # description	: This is example package
    # backup	: etc/example.conf etc/foobar.conf
    # conflict	: foobar2
    # depends	: package1 package2 package3
    # makedepends	: cmake gcc
    # noextract	: example.tar.gz foobar.tar.xz

    name=foobar
    version=1.0.0
    release=1
    options=(!docs libtool)
    source=(https://dl.example.com/foobar.tar.xz
            $name-$version.tar.gz::https://github.com/achieve/$version.tar.gz
            example.conf)

    build() {
        cd $name-$version
      
        ./configure --prefix=/usr
        make
        make DESTDIR=$PKG install
      
        install -d $SRC/example.conf $PKG/etc/example.conf
    }
    
You can also use headers (except for description, as it needs for search function of `scratch`) as array, example:

    backup=(etc/example.conf etc/foobar.conf)
    conflict=(foobar2)
    depends=(package1 package2 package3)
    makedepends=(cmake gcc)
    noextract=(example.tar.gz foobar.tar.xz)

*Note: When create new package, its recommended to build using fakeroot first to make sure the build script is not broken and leave untracked file inside system.*

#### spkgbuild format:

* `description`: Short description for package.
* `backup`: File need backup when upgrading package (without leading with '/').
* `conflict`: Specify package conflict, separate with space.
* `depends`: Dependencies and runtime dependencies, separate with space.
* `makedepends`: Make dependencies, checked only when build package, not checked when install prebuit package, separate with space.
* `noextract`: Specify file no need to extract, separate with space.
* `name`: Package name, need same as port directory's name.
* `version`: Package's version.
* `release`: Package's release version, useful when build script need change with same package version.
* `options`: Package's build options, see 'Package options' for available options.
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
    docs:        Keep docs directories specified by DOC_DIRS.
    purge:       Remove files specified in PURGE_FILES.
    zipman:      Compress manual (man and info) pages in MAN_DIRS with gzip.
    buildflags:  Enable buildflags (CFLAGS and CXXFLAGS).
    makeflags:   Enable makeflags (MAKEFLAGS).
    
## Scratchpkg tools

Scratchpkg tools is separate into 4 main tools and several extra scripts (may added from time to time).

### scratch
`scratch` is like multi tools. Its have many functions like search packages, check dependency, dependent, orphan package, duplicate ports, list installed package and etc. `scratch` also can build package without `cd` into port directory to build package. Run `scratch --help` to see available functions.

    Usage:
      scratch [ <options> <arguments> ]

    Options:
      -i,  --install                      install package
      -u,  --upgrade                      upgrade package
      -r,  --reinstall                    reinstall package
      -id, --ignore-dependency            skip dependency check
      -ic, --ignore-conflict              skip file/package conflict check
      -fr, --force-rebuild                rebuild package
      -sd, --source-dir <path>            override directory path for sources
      -pd, --package-dir <path>           override directory path for compiled package
      -v,  --verbose                      verbose process
      -im, --ignore-mdsum                 skip md5sum check for sources
      -um, --update-mdsum                 update md5sum file for port
      -do, --download-only                download sources only
      -eo, --extract-only                 extract sources only
      -kw, --keep-work                    keep working directory
      -rd, --redownload                   re-download sources
           --no-preinstall                skip preinstall script before build/install package
           --no-postinstall               skip postinstall script after install package
           --no-preupgrade                skip preupgrade script before upgrade package
           --no-postupgrade               skip postupgrade script after upgrade package
           --no-backup                    skip backup when upgrading package
      -p,  --package <pkgnames>           set package name to build
      -dup,--duplicate-ports              list duplicate ports
      -l,  --list-installed               show list installed packages
      -lp, --list-ports <repo>            show list ports for repository
      -lo, --list-orphan                  show list orphaned packages installed
      -ci, --check-integrity              check integrity between package's index and files in system
      -cu, --check-update                 check for package updatehes
      -up, --update-ports                 update port's repository
      -c,  --cat-port <pkgname>           print port's buildscript (spkgbuild)
      -dp, --dependent <pkgname>          show package's dependent (check through package index)
      -gdp,--global-dependent <pkgname>   show package's dependent (check through port's repository)
      -d,  --depends <pkgname>            show package's depends
      -pi, --package-info <pkg>           show package's info
      -co, --check-owner <file>           show file's owner
      -st, --show-tree <pkgname>          show list files of installed package
      -s,  --search <pattern>             search for packages in port's repository
      -t,  --create-template <portname>   create port's template for package
      -pp, --port-path                    show ports directory path
           --lock <pkgname>               lock package from upgrade
           --unlock <pkgname>             unlock package
           --listlocked                   list locked package
           --cache                        show old package and source caches
           --clear-cache                  remove all old package and source cac
           --missing-port                 list package that depends on non-exist port
           --missing-dep                  list package installed that missing it's dep in system
           --list-foreign                 list package installed but port not exist in repo
           --no-color                     disable colour for output
           --info                         show scratchpkg info (setting)
      -h,  --help                         show this help message
      
    Example:
      scratch -p firefox sudo -id -kw -i     build, keep working dir, ignore missing dependency
                                             and then install firefox and sudo

      scratch -r -fr -im -p firefox sudo     rebuild, skip md5sum check for sources and then
                                         reinstall firefox and sudo
                                        
### buildpkg
`buildpkg` is a tool to build package from ports. Is will source `spkgbuild` to get build information before creating package. Package is created into `<name>-<version>-<release>.spkg.txz` format. To build package, you need `cd` into port directory before run `buildpkg` command.

    Usage:
      buildpkg [ <options> <arguments> ]

    Options:
      -i,  --install             install package into system
      -u,  --upgrade             upgrade package
      -r,  --reinstall           reinstall package
      -id, --ignore-dependency   skip dependency check
      -ic, --ignore-conflict     ignore conflict when installing package
      -v,  --verbose             verbose install process
           --no-preinstall       skip preinstall script before build/install package
           --no-postinstall      skip postinstall script after install package
           --no-preupgrade       skip preupgrade script before upgrade package
           --no-postupgrade      skip postupgrade script after upgrade package
           --no-color            disable color
           --no-backup           skip backup when upgrading package
      -fr, --force-rebuild       rebuild package
      -im, --ignore-mdsum        skip md5sum checking
      -um, --update-mdsum        update md5sum
      -cm, --check-mdsum         check md5sum for source file
      -do, --download-only       download only source file
      -eo, --extract-only        extract only source file
      -kw, --keep-work           keep working directory
      -rd, --redownload          re-download source file
      -sd, --source-dir <path>   override directory path for sources
      -pd, --package-dir <path>  override directory path for compiled package
      -h,  --help                show this help message

    Example:
      buildpkg -fr -kw -i	this will force rebuild, install package and keep working directory

    Note:
      * use buildpkg without any options will only download source and build package by using other default options
      * buildpkg need run inside port directory
      
### installpkg
`installpkg` is a tool to install and upgrade package created by `buildpkg`. Install package is simply extract `<name>-<version>-<release>.spkg.txz` by using tar into real system then save list extracted file into package `INDEX_DIR`. Upgrading package is also using same extract as install, it will replace old files then compare list file from old and new package and remove old file which not exist in new package (like Slackware pkgtool does).

    Usage:
      installpkg package.spkg.txz [ <options> <arguments> ]

    Options:
      -u,  --upgrade              update package
      -r,  --reinstall            reinstall package
      -id, --ignore-dependency    skip dependency check
      -ic, --ignore-conflict      ignore conflict when installing package
      -v,  --verbose              verbose install process
           --no-preinstall        don't run pre-install script
           --no-postinstall       don't run post-install script
           --no-preupgrade        don't run pre-upgrade script
           --no-postupgrade       don't run post-upgrade script
           --no-backup            skip backup when upgrading package
           --no-orphan-check      skip orphaned package check after install package
           --no-color             disable colour for output
      -h,  --help                 show this help message

    Example:
      installpkg foobar-1.0-1.spkg.txz -u --no-backup        upgrade package foobar-1.0-1 without backup
                                                             its old configuration files
                                                             
### removepkg
`removepkg` is a tool to remove package from system. It will read file listed in package `INDEX_DIR` and remove it.

    Usage:
      removepkg package name [ <options> <arguments> ]

    Options:
      -id, --ignore-dependency    skip dependency check
      -v,  --verbose              verbose install process
           --no-preremove         don't run pre-remove script
           --no-postremove        don't run post-remove script
           --no-orphan-check      skip orphaned package check after install package
           --no-color             disable colour for output
      -h,  --help                 show this help message
    
    Example:
      removepkg firefox -id -v        remove package firefox, skipping dependency check
                                      and verbose deleted file

## Extra tools
Extra tools is some scripts come with scratchpkg to help users do things more easier. More extra scripts may added from time to time.

* `baseinstall`: A script to build base system.
* `chroot-scratch`: Chroot script.
* `depinstall`: Install package listed by `deplist`.
* `deplist`: Script for calculate all needed dependencies (dependencies order is not right).
* `libdepends`: Script to list package depends by shared libraries.
* `listinstall`: Install listed packages in a file.
* `revdep`: A reverse dependency script (like in Gentoo and CRUX, but my version), need to run after upgrade and remove package to check broken package(s). Specify package name if want to check single package only.
* `sysupdate`: An update script to update all outdated packages, use `-up|--update-ports` flags to sync ports first.
                                                             
## Hook

`hook` is specified command need to run after install/remove/upgrade package. `hook` suffix is `*.hook` and need to be placed in `HOOK_DIR` (default is `/etc/hook/`). The example of `hook` file for gdk-pixbuf package as follows:

    # description	: Probing GDK-Pixbuf loader modules...
    # operation	: install upgrade remove
    # target	: usr/lib/gdk-pixbuf-2.0/2.10.0/loaders/

    exechook() {
    	/usr/bin/gdk-pixbuf-query-loaders --update-cache
    }

### Hook format:

* `description`: Short description, printed when cmd executed.
* `operation`: Specify when cmd need to run, available options; install, upgrade & remove.
* `target`: Path file/directory checked need to run the cmd (without leading with '/').
* `exechook()`: Command need to run should be in this function.

## Install script

Install scripts is a bash script contains command need to run before/after install/upgrade/remove packages in system. The suffix of install script is `<portname>.install`. This install script need to placed in port directory and later will included in tar-ed package. The script contains the following functions which run at different times:

* `pre_install()`: The script is run right before package is built or files are extracted. One argument is passed: new package version.
* `post_install()`: The script is run right after files are extracted. One argument is passed: new package version.
* `pre_upgrade()`: The script is run right before files are extracted. Two arguments are passed in the following order: new package version, old package version.
* `post_upgrade()`: The script is run right after files are extracted. Two arguments are passed in the following order: new package version, old package version.
* `pre_remove()`: The script is run right before files are removed. One argument is passed: old package version.
* `post_remove()`: The script is run right after files are removed. One argument is passed: old package version.

Example of install script for `dbus.install`:

    pre_install() {
        getent group messagebus >/dev/null || groupadd -g 18 messagebus
        getent passwd messagebus >/dev/null || useradd -c "D-Bus Message Daemon User" -d /var/run/dbus -u 18 -g messagebus -s /bin/false messagebus
    }

    post_install() {
        dbus-uuidgen --ensure
    }

## Port file

Port file is a file contain URL of port's repository. The suffix of this port file is `<repository name>.httpup` (repository name should be same as PORT_REPO stated in `/etc/scratchpkg.conf`). This file will get read by `scratch` to sync the port's repository into system using a tool called `httpup`. By default, Port file need to placed into `/etc/ports`. Example of port file for `core` repository:

    URL=https://raw.githubusercontent.com/emmett1/ports/master/core

## Install

Installing is performed by just simply execute/running the file INSTALL.sh:

`./INSTALL.sh`

If packaging, append DESTDIR=/tmp/path in front of your command:

`DESTDIR=/tmp/path ./INSTALL.sh`
