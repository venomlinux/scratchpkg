scratchpkg
==========

A package manager for Linux From Scratch

Description
-----------

scratchpkg is a package manager were built to manage package for Linux From Scratch system. This package manager is fully written in bash. The script to build package using port system like Arch's makepkg, CRUX's pkgmk and NuTyX's cards. Package were build and install into temporary location using DESTDIR method then compressed the directory using tar.

Installing packaged tar is extract it into real system then write all files was extracted into index directory. So scratchpkg will track all files installed. scratchpkg does not automatically resolve dependency but it does checking for dependency before build the package and print the missing dependency.

scratchpkg read build script (spkgbuild) in ports directory to get all variables and functions needed before build it. All information of package will written into package like version, description, depends and etc. So the build package is not gonna need its ports anymore to get the information. This is really good when checking for package dependent or install package that was built from other machine.

Install
-------

Installing just simply execute INSTALL.sh:
'./INSTALL.sh'

If packaging, append DESTDIR=/tmp/path:
'DESTDIR=/tmp/path ./INSTALL.sh'
