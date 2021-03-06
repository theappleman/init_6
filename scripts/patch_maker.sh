#!/bin/bash

#
#  Copyright © 2012-2013 Andrey Ovcharov <sudormrfhalt@gmail.com>
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#  The latest version of this software can be obtained here:
#
#  https://github.com/init6/init_6/blob/master/scripts/patch_maker.sh
#

# Dependencies: portage, layman, init6 overlay, svn, git, lynx, wget, sed, awk, xz, dialog

ver=0.5

if [ "$#" -ne 1 ]
then
echo
echo "Usage:"
echo "`basename $0`-$ver kernel-version"
echo
exit 1
fi

if [ -e /etc/portage/make.conf ] ; then
	if [ -z "${DISTDIR}" ] ; then
		DISTDIR=$(source /etc/portage/make.conf 2>/dev/null ; echo ${DISTDIR})
	fi
fi

base=`grep ^storage /etc/layman/layman.cfg|sed "s/.*:.//"`/init6/sys-kernel/geek-sources/files-`date +"%Y%m%d"`

url_ls() {
	local url="$1"
	lynx -dump "$url" | sed 's/http/\^http/g' | tr -s "^" "\n" | grep http| sed 's/\ .*//g' | cut -c`echo -n "$1" | wc -m`- | cut -d"/" -f2 | grep -v "="
}

get_from_url() {
	local url="$1"
	local release="$2"
	shift
	wget -nd --no-parent --level 1 -r -R "*.html*" --reject "$release" \
	"$url/$release"
}

parse_svn_url() {
	svn info 2>/dev/null | sed -ne 's#^URL: ##p'
	# svn info 2>/dev/null | grep -e '^URL*' | sed -e 's#^URL: *\(.*\)#\1#g '
}

parse_svn_branch() {
	parse_svn_url | sed -e 's#^'"$(parse_svn_repository_root)"'##g' | awk -F / '{print "(svn::"$1 "/" $2 ")"}'
}

parse_svn_repository_root() {
	svn info 2>/dev/null | sed -ne 's#^Repository Root: ##p'
	# svn info 2>/dev/null | grep -e '^Repository Root:*' | sed -e 's#^Repository Root: *\(.*\)#\1\/#g '
}

parse_svn_revision() {
	svn info | grep Revision | tr -d 'Revison: '
}

git_info () {
	local LOCAL_BRANCH=`git name-rev --name-only HEAD`
	local TRACKING_BRANCH=`git config branch.$LOCAL_BRANCH.merge`
	local TRACKING_REMOTE=`git config branch.$LOCAL_BRANCH.remote`
	local REMOTE_URL=`git config remote.$TRACKING_REMOTE.url`
	shift
	echo " Generated by `basename $0` script v-$ver" >> "$CWD"/info
	echo " Grabbed on `date +"%F %T %Z"`" >> "$CWD"/info
	echo " url: `echo $REMOTE_URL`" >> "$CWD"/info
	echo " local branch: `echo $LOCAL_BRANCH`" >> "$CWD"/info
	echo " tracking branch: `echo $TRACKING_BRANCH`" >> "$CWD"/info
	echo " tracking remote: `echo $TRACKING_REMOTE`" >> "$CWD"/info
}

svn_info () {
	cd "$CSD"

	echo " Generated by `basename $0` script v-$ver" >> "$CWD"/info
	echo " Grabbed on `date +"%F %T %Z"`" >> "$CWD"/info
	echo " url: "`parse_svn_url` >> "$CWD"/info
	echo " branch: "`parse_svn_branch` >> "$CWD"/info
	echo " repository root: "`parse_svn_repository_root` >> "$CWD"/info
	echo " revision: "`parse_svn_revision` >> "$CWD"/info
}

# the kernel major version (e.g 3.4 for 3.4.2)
kmv(){
	local version="$1"
	shift
	echo "$version" | awk -F. '{ printf("%d.%d\n",$1,$2); }'
}

git_get_all_branches(){
	for branch in `git branch -a | grep remotes | grep -v HEAD | grep -v master`; do
		git branch --track ${branch##*/} $branch
	done
}

#aufs		git://aufs.git.sourceforge.net/gitroot/aufs/aufs3-standalone.git
#bfq		http://algo.ing.unimo.it/people/paolo/disk_sched/patches
#debian		svn://svn.debian.org/kernel/dists/trunk/linux/debian/patches
#fedora		git://pkgs.fedoraproject.org/kernel.git
#genpatches	svn://anonsvn.gentoo.org/linux-patches/genpatches-2.6/trunk
#grsecurity	git://git.overlays.gentoo.org/proj/hardened-patchset.git
#mageia		svn://svn.mageia.org/svn/packages/cauldron/kernel
#pld		git://github.com/pld-linux/kernel.git
#suse		git://kernel.opensuse.org/kernel-source.git
#ice		git://github.com/NigelCunningham/tuxonice-kernel.git
#spl		git://github.com/zfsonlinux/spl.git
#zfs		git://github.com/zfsonlinux/zfs.git
#zen		git://github.com/damentz/zen-kernel.git

get_or_bump() {
	local patch=$1
	local CSD="$DISTDIR/geek/$patch"
	shift
	if [ -d $CSD ]; then
		cd "$CSD"
		if [ -e ".git" ]; then # git
			git fetch --all;
			git pull --all;
		elif [ -e ".svn" ]; then # subversion
			svn up
		fi
	else
		case "$patch" in
		aufs) git clone "git://aufs.git.sourceforge.net/gitroot/aufs/aufs3-standalone.git" "$CSD"; cd "$CSD"; git_get_all_branches ;;
		debian) svn co "svn://svn.debian.org/kernel/dists/trunk/linux/debian/patches" "$CSD" ;;
		fedora) git clone "git://pkgs.fedoraproject.org/kernel.git" "$CSD"; cd "$CSD"; git_get_all_branches ;;
		genpatches) svn co "svn://anonsvn.gentoo.org/linux-patches/genpatches-2.6/trunk" "$CSD" ;;
		grsecurity) git clone "git://git.overlays.gentoo.org/proj/hardened-patchset.git" "$CSD"; cd "$CSD"; git_get_all_branches ;;
		mageia) svn co "svn://svn.mageia.org/svn/packages/cauldron/kernel" "$CSD" ;;
		suse) git clone "git://kernel.opensuse.org/kernel-source.git" "$CSD"; cd "$CSD"; git_get_all_branches ;;
#		ice) git clone "git://github.com/NigelCunningham/tuxonice-kernel.git" "$CSD"; cd "$CSD"; git_get_all_branches ;;
		esac
	fi
}

make_patch() {
	local patch="$1"
	local KERN=`kmv "$version"`;
	local CSD="$DISTDIR/geek/$patch";
	local CWD="$base/$version/$patch";
	shift
	case "$patch" in
	aufs)	cd "$CSD";
		test -d "$CWD" >/dev/null 2>&1 || mkdir -p "$CWD";
		get_or_bump "$patch";
		cp -r "$CSD" /tmp/aufs$$;
		cd /tmp/aufs$$;
		dir=(
		"Documentation"
		"fs"
		"include"
		)
		dest="$CWD"/aufs3-"$KERN"-`date +"%Y%m%d"`.patch;

		git branch
		echo "Please enter $patch branch:"
		read branch # the branch you want
		echo "You entered: $branch";

		git checkout origin/"$branch"; git pull;

		mkdir ../a ../b
		cp -r {Documentation,fs,include} ../b
#		rm ../b/include/linux/Kbuild
		rm ../b/include/uapi/linux/Kbuild
		cd ..

		for i in "${dir[@]}";
			do diff -U 3 -dHrN -- a/ b/"$i"/ >> "$dest";
			sed -i "s:a/:a/"$i"/:" "$dest";
			sed -i "s:b:b:" "$dest";
		done
		rm -rf /tmp/a /tmp/b;

		cp /tmp/aufs$$/aufs3-base.patch "$CWD"/aufs3-base-"$KERN"-`date +"%Y%m%d"`.patch;
		cp /tmp/aufs$$/aufs3-standalone.patch "$CWD"/aufs3-standalone-"$KERN"-`date +"%Y%m%d"`.patch;
		cp /tmp/aufs$$/aufs3-kbuild.patch "$CWD"/aufs3-kbuild-"$KERN"-`date +"%Y%m%d"`.patch;
		cp /tmp/aufs$$/aufs3-proc_map.patch "$CWD"/aufs3-proc_map-"$KERN"-`date +"%Y%m%d"`.patch;
		cp /tmp/aufs$$/aufs3-loopback.patch "$CWD"/aufs3-loopback-"$KERN"-`date +"%Y%m%d"`.patch;

		cd /tmp/aufs$$;
		git_info;
		rm -rf /tmp/aufs$$;

		ls -1 "$CWD" | grep ".patch" > "$CWD"/patch_list;
	;;
	bfq)	test -d "$CWD" >/dev/null 2>&1 || mkdir -p "$CWD";
		cd "$CWD";
		url_ls "http://algo.ing.unimo.it/people/paolo/disk_sched/patches";

		echo "Please enter bfq release:"
		read release # the release you want
		echo "You entered: $release";

		get_from_url "http://algo.ing.unimo.it/people/paolo/disk_sched/patches" "$release";

		ls -1 "$CWD" | grep ".patch" > "$CWD"/patch_list;

		shift
		echo " Generated by `basename $0` script v-$ver" >> "$CWD"/info
		echo " Grabbed on `date +"%F %T %Z"`" >> "$CWD"/info
		echo " From: http://algo.ing.unimo.it/people/paolo/disk_sched/patches/$release" >> "$CWD"/info
	;;
	debian) cd "$CSD";
		test -d "$CWD" >/dev/null 2>&1 || mkdir -p "$CWD";
		get_or_bump "$patch";

		cp -r "$CSD" /tmp/debian$$;
		cd /tmp/debian$$;

		find -name .svn -type d -exec rm -rf {} \;
		find -type d -empty -delete

		mv series patch_list;

		rm -rf series-orig
		rm -rf debian/dfsg/

		rm -rf series-rt
		rm -rf features/all/rt/

		rm -rf features/all/aufs3/gen-patch
		rm -rf features/all/vserver/

		cp -r * "$CWD"

		rm -rf /tmp/debian$$

		svn_info;
	;;
	fedora) cd "$CSD";
		test -d "$CWD" >/dev/null 2>&1 || mkdir -p "$CWD";
		get_or_bump "$patch";

		cp -r "$CSD" /tmp/fedora$$;
		cd /tmp/fedora$$;

		git branch
		echo "Please enter $patch branch:"
		read branch # the branch you want
		echo "You entered: $branch";
		git checkout "$branch"; git pull;

		ls -1 | grep ".patch" | xargs -I{} cp "{}" "$CWD"

		cat kernel.spec | sed -n '/### BRANCH APPLY ###/ ,/# END OF PATCH APPLICATIONS/p' | sed 's/ApplyPatch //g' | sed 's/ApplyOptionalPatch //g' | sed 's/ pplyPatch //g' | sed -n '/%endif/ ,/%endif/!p' | sed -e '/^%/d' | sed 's/ -R//g' > "$CWD"/patch_list

		cd /tmp/fedora$$
		git_info;
		rm -rf /tmp/fedora$$
	;;
	genpatches) cd "$CSD";
		test -d "$CWD" >/dev/null 2>&1 || mkdir -p "$CWD";
		cd "$CWD";
#		get_from_url "http://dev.gentoo.org/~mpagano/genpatches/trunk" "$KERN";

		get_or_bump "$patch";

		cp -r "$CSD" /tmp/genpatches$$;
		cd /tmp/genpatches$$/"$KERN";

		find -name .svn -type d -exec rm -rf {} \;
		find -type d -empty -delete

		ls -1 | grep "linux" | xargs -I{} rm -rf "{}";
		ls -1 | grep ".patch" > "$CWD"/patch_list;

		cp -r /tmp/genpatches$$/"$KERN"/* "$CWD"

		rm -rf /tmp/genpatches$$

		svn_info;
	;;
	grsecurity) cd "$CSD";
		test -d "$CWD" >/dev/null 2>&1 || mkdir -p "$CWD";
		get_or_bump "$patch";

		cp -r "$CSD" /tmp/grsecurity$$;
		ls -1 /tmp/grsecurity$$;

		echo "Please enter grsecurity release:"
		read release # the release you want
		echo "You entered: $release";

		cd /tmp/grsecurity$$/"$release";

		ls -1 | xargs -I{} cp "{}" "$CWD";

		cd /tmp/grsecurity$$;
		git_info;
		rm -rf /tmp/grsecurity$$;

		ls -1 "$CWD" | grep ".patch" > "$CWD"/patch_list;
	;;
	ice)	#cd "$CSD";
		test -d "$CWD" >/dev/null 2>&1 || mkdir -p "$CWD";
#		get_or_bump "$patch";

#		git checkout vanilla-"$KERN"; git pull;
#		git checkout tuxonice-"$KERN"; git pull;
		dest="$CWD"/tuxonice-kernel-"$version"-`date +"%Y%m%d"`.patch;
#		git diff vanilla-"$KERN" tuxonice-"$KERN" > "$dest";
		wget "https://github.com/NigelCunningham/tuxonice-kernel/compare/vanilla-$KERN...tuxonice-$KERN.diff" -O "$dest"
		cd "$CWD";
		ls -1 | grep ".patch" | xargs -I{} xz "{}" | xargs -I{} cp "{}" "$CWD";
		ls -1 "$CWD" | grep ".patch.xz" > "$CWD"/patch_list;

#		cd "$CSD";
#		git_info;
	;;
	mageia) cd "$CSD";
		test -d "$CWD" >/dev/null 2>&1 || mkdir -p "$CWD";
		get_or_bump "$patch";

		cp -r "$CSD" /tmp/mageia$$;
		cd /tmp/mageia$$/releases/"$version";

		ls -1
		echo "Please enter mageia release: "
		read release # the release you want
		echo "You entered: $release"
		cd /tmp/mageia$$/releases/"$version"/"$release"/PATCHES;

		find . -name "*.patch" | xargs -i cp "{}" "$CWD";

		cat patches/series | sed 's/3rd-/#3rd-/g' > "$CWD"/patch_list;

		rm -rf /tmp/mageia$$

		svn_info;
	;;
	suse)	cd "$CSD";
		test -d "$CWD" >/dev/null 2>&1 || mkdir -p "$CWD";
		get_or_bump "$patch";

		cp -r "$CSD" /tmp/suse$$;

		cd /tmp/suse$$;

		git branch
		echo "Please enter $patch branch:"
		read branch # the branch you want
		echo "You entered: $branch";
		git checkout "$branch"; git pull;

		cp -r patches.*/ "$CWD";

		cat series.conf | sed -n '/# Kernel patches configuration file/ ,/# own build environment./!p' | sed 's/+needs_update?/\#/g' | sed 's/+needs_update37/\#/g' | sed 's/+needs_updating-39/\#/g' | sed 's/+needs_update/\#/g' | sed 's/+trenn/\#/g' | sed 's/+hare/\#/g'| sed 's/+jeffm/\#/g' | sed 's/+update_xen/\#/g' | sed 's/+xen_needs_update/\#/g' | sed 's/[\t]//g' | sed 's/        //g' > "$CWD"/patch_list;

		cd /tmp/suse$$;
		git_info;
		rm -rf /tmp/suse$$;
	;;
	zfs)	[ "${zfs_patch_type}" = "grsecurity" ] && CWD="$CWD/grsecurity";
		[ "${zfs_patch_type}" = "vanilla" ] && CWD="$CWD/vanilla";
		test -d "$CWD" >/dev/null 2>&1 || mkdir -p "$CWD";
		if [ -e /etc/portage/make.conf ] ; then
			if [ -z "${PORTDIR}" ] ; then
				PORTDIR=$(source /etc/portage/make.conf 2>/dev/null ; echo ${PORTDIR})
			fi
			if [ -z "${PORTAGE_TMPDIR}" ] ; then
				PORTAGE_TMPDIR=$(source /etc/portage/make.conf 2>/dev/null ; echo ${PORTAGE_TMPDIR})
			fi
		fi

		[ "${zfs_patch_type}" = "grsecurity" ] && env USE="grsecurity -branding -fedora -genpatches -ice -mageia -reiser4 -suse -symlink -aufs -bfq -build -ck -debian -deblob -lqx -pax -pf -rt -uksm -zen -zfs" ebuild `grep ^storage /etc/layman/layman.cfg|sed "s/.*:.//"`/init6/sys-kernel/geek-sources/geek-sources-"$version".ebuild compile;
		[ "${zfs_patch_type}" = "vanilla" ] && ebuild `grep ^storage /etc/layman/layman.cfg|sed "s/.*:.//"`/init6/sys-kernel/geek-sources/geek-sources-"$version".ebuild unpack;
		mv "$PORTAGE_TMPDIR"/portage/sys-kernel/geek-sources-"$version"/work/linux-"$version"-geek "$PORTAGE_TMPDIR"/portage/a
		rm -r "$PORTAGE_TMPDIR"/portage/sys-kernel
		cd "$PORTAGE_TMPDIR"/portage/a
		make mrproper
		cd "$PORTAGE_TMPDIR"/portage
		cp -r a b

		unlink /usr/src/linux
		ln -s "$PORTAGE_TMPDIR"/portage/b /usr/src/linux

		# Prepare kernel sources
		cd "$PORTAGE_TMPDIR"/portage/b
		zcat /proc/config.gz > .config
		make oldconfig && make prepare && make modules_prepare

		ls -1 "$PORTDIR"/sys-kernel/spl | grep ebuild | sed 's/spl-//g' | sed 's/.ebuild//g'

		echo "Please enter sys-kernel/spl release:"
		read spl_version # the release you want
		echo "You entered: $spl_version";

		# Integrate SPL
		env EXTRA_ECONF='--prefix=/ --libdir=/lib64 --includedir=/usr/include --datarootdir=/usr/share --enable-linux-builtin=yes --with-linux='"$PORTAGE_TMPDIR"'/portage/b --with-linux-obj='"$PORTAGE_TMPDIR"'/portage/b' ebuild "$PORTDIR"/sys-kernel/spl/spl-"$spl_version".ebuild clean configure
		cd "$PORTAGE_TMPDIR"/portage/sys-kernel/spl-"$spl_version"/work/spl-spl-"$spl_version"
		./copy-builtin "$PORTAGE_TMPDIR"/portage/b

		ls -1 "$PORTDIR"/sys-fs/zfs-kmod | grep ebuild | sed 's/zfs-kmod-//g' | sed 's/.ebuild//g'

		echo "Please enter sys-fs/zfs-kmod release:"
		read zfs_version # the release you want
		echo "You entered: $zfs_version";

		# Integrate ZFS
		env EXTRA_ECONF='--prefix=/ --libdir=/lib64 --includedir=/usr/include --datarootdir=/usr/share --enable-linux-builtin=yes --with-linux='"$PORTAGE_TMPDIR"'/portage/b --with-linux-obj='"$PORTAGE_TMPDIR"'/portage/b --with-spl='"$PORTAGE_TMPDIR"'/portage/sys-kernel/spl-'"$spl_version"'/work/spl-spl-'"$spl_version"' --with-spl-obj='"$PORTAGE_TMPDIR"'/portage/sys-kernel/spl-'"$spl_version"'/work/spl-spl-'"$spl_version"'' ebuild "$PORTDIR"/sys-fs/zfs-kmod/zfs-kmod-"$zfs_version".ebuild clean configure

		cd "$PORTAGE_TMPDIR"/portage/sys-fs/zfs-kmod-"$zfs_version"/work/zfs-zfs-"$zfs_version"
		./copy-builtin "$PORTAGE_TMPDIR"/portage/b

		rm -r "$PORTAGE_TMPDIR"/portage/sys-kernel/spl-"$spl_version"
		rm -r "$PORTAGE_TMPDIR"/portage/sys-fs/zfs-kmod-"$zfs_version"

		cd "$PORTAGE_TMPDIR"/portage/b
		make mrproper

		cd "$PORTAGE_TMPDIR"/portage
		diff -urN a/ b/ > "$CWD"/zfs-"$zfs_patch_type"-builtin-"$version"-`date +"%Y%m%d"`.patch

		cd "$CWD";
		ls -1 | grep ".patch" | xargs -I{} xz "{}" | xargs -I{} cp "{}" "$CWD";
		ls -1 "$CWD" | grep ".patch.xz" > "$CWD"/patch_list;

		unlink /usr/src/linux
		echo "Now make eselect kernel list && eselect kernel set <some number>"

		shift
		echo " Generated by `basename $0` script v-$ver" >> "$CWD"/info
		echo " Grabbed on `date +"%F %T %Z"`" >> "$CWD"/info
		echo " zfs-builtin-$version-`date +"%Y%m%d"`.patch.xz based on:" >> "$CWD"/info
		echo " sys-kernel/spl-`echo $spl_version`" >> "$CWD"/info
		echo " sys-fs/zfs-kmod-`echo $zfs_version`" >> "$CWD"/info

		cd "$PORTAGE_TMPDIR/portage"
		rm -rf a b sys-fs sys-kernel;
	;;
	esac
}

version="$1"

cmd=(dialog --menu "Update patches:" 22 76 16)
options=(1 "One or several of"
         2 "All")
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for choice in $choices
do
	case $choice in
	1) cmd=(dialog --separate-output --checklist "Select patch:" 22 76 16)
	options=(0 "aufs" off
		 1 "bfq" off
		 2 "debian" off
		 3 "fedora" off
		 4 "genpatches" off
		 5 "grsecurity" off
		 6 "ice" off
		 7 "mageia" off
		 8 "suse" off
		 9 "zfs" off)
	choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
	clear
	for choice in $choices
	do
		case $choice in
		0) patches="$patches aufs"
		;;
		1) patches="$patches bfq"
		;;
		2) patches="$patches debian"
		;;
		3) patches="$patches fedora"
		;;
		4) patches="$patches genpatches"
		;;
		5) patches="$patches grsecurity"
		;;
		6) patches="$patches ice"
		;;
		7) patches="$patches mageia"
		;;
		8) patches="$patches suse"
		;;
		9) cmd=(dialog --separate-output --checklist "Select zfs patch:" 22 76 16)
		zfs_options=(0 "grsecurity" off
			     1 "vanilla" off)
		zfs_choices=$("${cmd[@]}" "${zfs_options[@]}" 2>&1 >/dev/tty)
		clear
		for zfs_choice in $zfs_choices ; do
		case $zfs_choice in
			0) zfs_patch_type="grsecurity"; make_patch "zfs" ;;
			1) zfs_patch_type="vanilla"; make_patch "zfs" ;;
		esac
		done
		;;
		esac
	done
	;;
	2) patches="aufs bfq debian fedora genpatches grsecurity ice mageia suse"
	zfs_patch_type="grsecurity"; make_patch "zfs"
	zfs_patch_type="vanilla"; make_patch "zfs"
	;;
	esac
done

for cur_patch in $patches; do
	make_patch "$cur_patch";
done;

echo -en "\033[1;32m Enjoy ;) \n"
