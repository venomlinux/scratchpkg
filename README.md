scratchpkg
==========

A package manager for Linux From Scratch

Description
-----------

Scratchpkg is a package manager built in order to manage packages for the Linux From Scratch system/distro. This package manager is fully written in bash. The package building script uses the port system like in Arch's makepkg, CRUX's pkgmk and NuTyX's cards. Packages are built and installed into a temporary location using DESTDIR method and are afterwards compressed in a file  directory using tar.

Installing the packaged tar means it is extracted into real system. After that all files are extracted into an index directory. So scratchpkg will track all installed files. Scratchpkg doesn't automatically resolve dependencies but it checks dependencies before building the package and prints the missing dependency.

Scratchpkg reads the build script (spkgbuild) in the ports directory in order to get all necessary variables and functions before building them. Full package information  like version, description, depends etc ... will be written into the package. So the built package isn't needing its port anymore for getting the necessary information. This is really an advantage supposing you would like to check for package dependencies or install a package that was built for another machine.

Install
-------

Installing is performed by just simply execute/ running the file INSTALL.sh:

`./INSTALL.sh`

If packaging, append DESTDIR=/tmp/path in front of your command:

`DESTDIR=/tmp/path ./INSTALL.sh`
