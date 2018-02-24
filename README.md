# scratchpkg

A package manager for Linux From Scratch

## Description

Scratchpkg is a package manager built in order to manage packages for the Linux From Scratch system/distro. This package manager is fully written in bash. The package building script uses the port system like in Arch's makepkg, CRUX's pkgmk and NuTyX's cards. Packages are built and installed into a temporary location using DESTDIR method and are afterwards compressed in a file  directory using tar.

Installing the packaged tar means it is extracted into real system. After that all files are extracted into an index directory. So scratchpkg will track all installed files. Scratchpkg doesn't automatically resolve dependencies but it checks dependencies before building the package and prints the missing dependency.

Scratchpkg reads the build script (spkgbuild) in the ports directory in order to get all necessary variables and functions before building them. Full package information  like version, description, depends etc ... will be written into the package. So the built package isn't needing its port anymore for getting the necessary information. This is really an advantage supposing you would like to check for package dependencies or install a package that was built for another machine.

## Install

Installing is performed by just simply execute/ running the file INSTALL.sh:

`./INSTALL.sh`

If packaging, append DESTDIR=/tmp/path in front of your command:

`DESTDIR=/tmp/path ./INSTALL.sh`

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
      
      install -dm $SRC/example.conf $PKG/etc/example.conf
    }
    
You can also use headers (except for description, as it needs for search function of `scratch`) as array, example: depends=(package1 package2 package3).

#### Format
* `description`: short description for package
* `backup`: file need backup when upgrading package
* `conflict`: specify package conflict, separate with space
* `depends`: dependencies and runtime dependencies, separate with space
* `makedepends`: make dependencies, need only when build package, no need when install prebuit package, separate with space
* `noextract`: specify file no need to extract, separate with space

* `name`: package name, need same as port directory
* `version`: package's version
* `release`: package's release version, useful when build script need change with same same package version
* `options`: package's build options, see 'Package options' for available options
* `source`: package's source urls, separate with space, can use as '$name-$version.tar.gz::https://github.com/achieve/$version.tar.gz
    
## Package options

    libtool:     Keep libtool file (*.la) in packages
    emptydirs:   Keep empty directories in packages
    strip:       Strip symbols from binaries/libraries
    docs:        Keep docs directories specified by DOC_DIRS
    purge:       Remove files specified in PURGE_FILES
    zipman:      Compress manual (man and info) pages in MAN_DIRS with gzip
    buildflags:  Enable buildflags (CFLAGS and CXXFLAGS)
    makeflags:   Enable makeflags (MAKEFLAGS)
  
this option is set in `/etc/scratchpkg.conf` for global options: `OPTIONS=()`

or set in packages spkgbuild for per package: `options=()`

## Scratchpkg tools
### scratch
    Usage:

      scratch [ <options> <arguments> ]
    
    Options:
      -i,  --install              install package
      -u,  --upgrade              upgrade package
      -r,  --reinstall            reinstall package
      -id, --ignore-dependency    skip dependency check
      -ic, --ignore-conflict      skip file/package conflict check
      -fr, --force-rebuild        rebuild package
      -sd, --source-dir <path>    set directory path for sources
      -pd, --package-dir <path>   set directory path for compiled package
      -v,  --verbose              verbose process
      -im, --ignore-mdsum         skip md5sum check for sources
      -um, --update-mdsum         update md5sum file for port
      -do, --download-only        download sources only
      -eo, --extract-only         extract sources only
      -kw, --keep-work            keep working directory
      -rd, --redownload           re-download sources
           --no-preinstall        don't run pre-install script
           --no-postinstall       don't run post-install script
           --no-backup            skip backup when upgrading package
      -dup,--duplicate-ports      list duplicate ports
      -l,  --list-installed       show list installed packages
      -lp, --list-ports           show list ports for repository
      -lo, --list-orphan          show list orphaned packages installed
      -ci, --check-integrity      check integrity between package's index and files in system
      -cu, --check-update         check for package update
           --cache                show old package and source caches
           --clear-cache          remove all old package and source caches
      -up, --update-ports         update port's repository
           --info                 show scratchpkg info (setting)
      -c,  --cat-port             cat port's buildscript (spkgbuild)
      -dp, --dependent            show package's dependent (check through package index)
      -gdp,--global-dependent     show package's dependent (check through port's repository)
      -d,  --depends              show package's depends
      -pi, --package-info <pkg>   show package's info
      -co, --check-owner          show file's owner
      -p,  --package              set package name to build/install
      -st, --show-tree            show list files of installed package
      -s,  --search               search for packages in port's repository
      -t,  --create-template      create port's template for package
      -pp, --port-path            show ports directory path
           --no-color             disable colour for output
      -h,  --help                 show this help message
      
    Example:
      scratch -p firefox -id -kw -i     build, keep working dir, ignore missing dependency
                                        and then install firefox

      scratch -r -fr -im -p firefox     rebuild, skip md5sum check for sources and then
                                        reinstall firefox
                                        
### buildpkg
    Usage:
      buildpkg [ <options> <arguments> ]

    Options:
      -i,  --install             install package into system
      -u,  --upgrade             upgrade package
      -r,  --reinstall           reinstall package
      -id, --ignore-dependency   skip dependency check
      -ic, --ignore-conflict     ignore conflict when installing package
           --verbose             verbose install process
           --no-preinstall       skip preinstall script when build/install package
           --no-postinstall      skip postinstall script after install package
           --no-color            disable color
      -fr, --force-rebuild       rebuild package
      -im, --ignore-mdsum        skip md5sum checking
      -um, --update-mdsum        update md5sum
      -cm, --check-mdsum         check md5sum for source file
      -do, --download-only       download only source file
      -eo, --extract-only        extract only source file
      -kw, --keep-work           keep working directory
      -ns, --no-strip            skip strip package library and binary
      -rd, --redownload          re-download source file
      -sd, --source-dir <path>   override source dir
      -pd, --package-dir <path>  set directory path for compiled package
      -h,  --help                show this help message

    Example:
      buildpkg -fr -kw -i	this will force rebuild, install package and keep working directory

    Note:
      * use buildpkg without any options will only download source and build package by using other default options
      * buildpkg need run inside port directory
      
### installpkg
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
                                                             
# test1
## test2
### test3
