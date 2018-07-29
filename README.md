# scratchpkg

Пакетный менеджер для Linux From Scratch.

## Description

Scratchpkg - программа управления пакетами (пакетный менеджер) для LFS (Linux From Scratch). Scratchpkg написан на bash. Сценарии сборки пакетов использует систему портов, похожую на makepkg у ArchLinux, pkgmk у CRUX и NuTyX cards. Пакеты собираются и устанавливаются во временный каталог с помощью метода DESTDIR, а затем архивируются в каталог с помощью tar.

Процедура установки пакета заключается в распаковке архива в рабочую систему, после чего список распакованных файлов будет записан в index каталог. Таким образом scratchpkg будет отслеживать все установленные файлы. Также, Scratchpkg может автоматически разрешать зависимости, и их порядок.

Scratchpkg читает файл сценария сборки (spkgbuild) в каталоге портов и определяет все необходимые переменные и функции перед тем как начать процесс сборки. Полная информация о пакете, такая как версия, описания и зависимости и т.д. записана в файле пакета. Поэтому собираемый пакет более не будет нуждаться в его порте для получения необходимой информации. Это является преимуществом, если вы хотите проверить зависимости пакетов или установить пакет, который был создан для другой машины.

## spkgbuild

`spkgbuild` is build script sourced by `buildpkg` to build the package.
The example of `spkgbuild` as follows:

    # description	: This is example package
    # backup	: etc/example.conf etc/foobar.conf
    # conflict	: foobar2
    # depends	: package1 package2 package3
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
    noextract=(example.tar.gz foobar.tar.xz)

*Note: When create new package, its recommended to build using fakeroot first to make sure the build script is not broken and leave untracked file inside system.*

#### spkgbuild format:

* `description`: Short description for package.
* `backup`: File need backup when upgrading package (without leading with '/').
* `conflict`: Specify package conflict, separate with space.
* `depends`: All required dependencies, separate with space.
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
`scratch` is like multi tools. Its have many functions like search packages, check dependency, dependent, orphan package, duplicate ports, list installed package and etc. `scratch` also can build package without `cd` into port directory to build package. Run `scratch help` to see available functions.

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
                                        
### buildpkg
`buildpkg` is a tool to build package from ports. Is will source `spkgbuild` to get build information before creating package. Package is created into `<name>-<version>-<release>.spkg.txz` format. To build package, you need `cd` into port directory before run `buildpkg` command.

    Usage:
      buildpkg [ <options> <arguments> ]

    Options:
      -i, --install             install package into system
      -u, --upgrade             upgrade package
      -r, --reinstall           reinstall package
      -d, --no-dep              skip dependency check
      -c, --ignore-conflict     ignore conflict when installing package
      -v, --verbose             verbose install process
      -f, --force-rebuild       rebuild package
      -m, --ignore-mdsum        skip md5sum checking
      -g, --genmdsum            generate md5sum
      -o, --download-only       download only source file
      -e, --extract-only        extract only source file
      -w, --keep-work           keep working directory
      -h, --help                show this help message
          --srcdir=<path>       override directory path for sources
          --pkgdir=<path>       override directory path for compiled package
          --no-preinstall       skip preinstall script before build/install package
          --no-postinstall      skip postinstall script after install package
          --no-preupgrade       skip preupgrade script before upgrade package
          --no-postupgrade      skip postupgrade script after upgrade package
          --no-color            disable color
          --no-backup           skip backup configuration file when upgrading package
          --redownload          re-download source file

    Example:
      buildpkg -irw	        this will force rebuild, install package and keep working directory

    Note:
      * use buildpkg without any options will only download source and build package by using other default options
      * buildpkg need run inside port directory

      
### installpkg
`installpkg` is a tool to install and upgrade package created by `buildpkg`. Install package is simply extract `<name>-<version>-<release>.spkg.txz` by using tar into real system then save list extracted file into package `INDEX_DIR`. Upgrading package is also using same extract as install, it will replace old files then compare list file from old and new package and remove old file which not exist in new package (like Slackware pkgtool does).

    Usage:
      installpkg package.spkg.txz <options>

    Options:
      -u, --upgrade              upgrade package
      -r, --reinstall            reinstall package
      -d, --no-dep               skip dependency check
      -c, --ignore-conflict      ignore conflict when installing package
      -v, --verbose              print files installed
      -h, --help                 show this help message
          --no-preinstall        skip preinstall script before build/install package
          --no-postinstall       skip postinstall script after install package
          --no-preupgrade        skip preupgrade script before upgrade package
          --no-postupgrade       skip postupgrade script after upgrade package
          --no-backup            skip backup when upgrading package
          --no-orphan-check      skip orphaned package check after install package
          --no-color             disable colour for output

    Example:
      installpkg foobar-1.0-1.spkg.txz -uc --no-backup       upgrade package foobar-1.0-1 without backup its 
                                                             old configuration files and skip conflict check
                                                             
### removepkg
`removepkg` is a tool to remove package from system. It will read file listed in package `INDEX_DIR` and remove it.

    Usage:
      removepkg [ <options> <package name> ]

    Options:
      -d, --no-dep          skip dependency check
      -v, --verbose         print removed files
      -h, --help            show this help message
          --no-preremove    don't run pre-remove script
          --no-postremove   don't run post-remove script
          --no-color        disable colour for output

    Example:
      removepkg firefox -dv --no-preremove       remove package firefox, skipping dependency check,
                                                 print deleted files and skipp pre-remove script

## Extra tools
Extra tools is some scripts come with scratchpkg to help users do things more easier. More extra scripts may added from time to time.

* `s-baseinstall`: Script to build base system.
* `s-chroot`: Chroot script.
* `s-deplist`: Script for calculate all needed dependencies.
* `s-libdepends`: Script to list package depends by shared libraries.
* `s-portcreate`: Script to create template port.
* `s-updateconf`: Script to update configuration files (*.spkgnew).
* `revdep`: A reverse dependency script (like in Gentoo and CRUX, but my version), need to run after upgrade and remove package to check broken package(s). Specify package name if want to check single package only.
                                                             
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

## /etc/scratchpkg.repo

`/etc/scratchpkg.repo` is file to define repo directory and url to sync/update port's. This is example default `/etc/scratchpkg.repo`;

    #
    # /etc/scratchpkg.repo : scratchpkg repo file
    #
    # format:
    #    <repo directory> <repo url for sync>
    #

    /usr/ports/core  https://raw.githubusercontent.com/emmett1/ports/master/core
    /usr/ports/xorg  https://raw.githubusercontent.com/emmett1/ports/master/xorg
    /usr/ports/xfce4 https://raw.githubusercontent.com/emmett1/ports/master/xfce4
    /usr/ports/kf5   https://raw.githubusercontent.com/emmett1/ports/master/kf5
    /usr/ports/lxde  https://raw.githubusercontent.com/emmett1/ports/master/lxde
    /usr/ports/extra https://raw.githubusercontent.com/emmett1/ports/master/extra
    /usr/ports/git   https://raw.githubusercontent.com/emmett1/ports/master/git
    /usr/ports/wip   https://raw.githubusercontent.com/emmett1/ports/master/wip
    
*Note: url is optional. Add if need to sync it.*


## Install

Installing is performed by just simply execute/running the file INSTALL.sh:

`./INSTALL.sh`

If packaging, append DESTDIR=/tmp/path in front of your command:

`DESTDIR=/tmp/path ./INSTALL.sh`
