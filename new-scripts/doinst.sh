#!/ffp/bin/sh
set -e
export SHELL="/ffp/bin/sh"
export PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
deps="br2:libtorrent-0.16.16_svn9886-arm-2.txz br2:deluge-1.3.6_git20140415-arm-1.txz"
echo -e "\e[1;32;20mResolving dependant packages ...\e[0m"
for dep in $deps; do
	pkg=$(echo $dep | cut -f2 -d ':' | awk -F'.txz' '{print $1}')
	repo=$(echo $dep | awk -F':' '{print $1}')
	if grep ^$repo /ffp/funpkg/cache/sites >> /dev/null; then 
		repourl=$(grep ^$repo /ffp/funpkg/cache/sites | awk '{print $2}')
	else
		echo "Requested $repo repository doesn't exists in database"
		echo "Use uwsiteloadertool to add $repo repository to FFP sites database"
		exit 0
	fi
	if grep $pkg /ffp/funpkg/cache/$repo/CHECKSUMS.md5 >> /dev/null; then
		pkgfullpath="$(grep $pkg /ffp/funpkg/cache/$repo/CHECKSUMS.md5 | awk '{print $2}')"
	else
		echo "Dependand $pkg package was not found in $repo repository!"
		echo "Try to update list of packages with command: slacker -U"
		exit 0
	fi
	if test -f /ffp/funpkg/installed/$pkg; then
		echo -e "$dep is already installed. \e[1;32;20m[ OK ]\e[0m"
	else
		echo -e "$dep is not installed. \e[1;33;20m[ QUEUED ]\e[0m"
		cd /ffp/funpkg/cache/$repo
		if test -f $pkg.txz; then
			echo "Requested $pkg.txz was found in cache-/ffp/funpkg/cache/$repo"
			funpkg -u $pkg.txz
			if [ "$(funpkg -u $pkg.txz)" = "$pkg: Not installed" ] >> /dev/null; then
				funpkg -i $pkg.txz
			fi
		else
			echo "Requested $pkg.txz was not found in cache-/ffp/funpkg/cache/$repo"
			echo "Downloading $pkg ..."
			wget -nv $repourl/$pkgfullpath
			funpkg -u $pkg.txz
			if [ "$(funpkg -u $pkg.txz)" = "$pkg: Not installed" ] >> /dev/null; then
				funpkg -i $pkg.txz
			fi
		fi
	echo -e "\e[1;32;20mDependent packages installed successfully! [ OK ]\e[0m"
	fi
done
