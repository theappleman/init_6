init6 overlay
=============

At this unofficial place, i publish some ebuilds that may (or may not) be interesting to other Gentoo users.

**USE AT YOUR OWN RISK.**

You are supposed to be using **~amd64** or **~x86** if you use this overlay.
Please report any failure or missing dep.
You can also request to add any ebuild.

For add overlay
---------------

Install layman

    emerge -av layman

and run

    layman -a init6

If you've never worked with a overlay, please read [Gentoo Overlays: Users' Guide](http://www.gentoo.org/proj/en/overlays/userguide.xml)

In this overlay you will find
-----------------------------
 * [app-admin/perl-cleaner](https://github.com/init6/init_6/tree/master/app-admin/perl-cleaner), [app-admin/python-updater](https://github.com/init6/init_6/tree/master/app-admin/python-updater), [app-portage/gentoolkit](https://github.com/init6/init_6/tree/master/app-portage/gentoolkit), [sys-devel/binutils-config](https://github.com/init6/init_6/tree/master/sys-devel/binutils-config), [sys-devel/gcc-config](https://github.com/init6/init_6/tree/master/sys-devel/gcc-config) my fix of [bug #373219](https://bugs.gentoo.org/show_bug.cgi?id=373219) 
 * [app-emulation/wine](https://github.com/init6/init_6/tree/master/app-emulation/wine) with desktop and icon files and with with [with Maarten Lankhorst's multimedia patches, including PulseAudio support](http://repo.or.cz/w/wine/multimedia.git)
 * [app-misc/mc](https://github.com/init6/init_6/tree/master/app-misc/mc) with desktop and icon files
 * [dev-vcs/gitflow](https://github.com/init6/init_6/tree/master/dev-vcs/gitflow) fix for [bug #419943](https://bugs.gentoo.org/show_bug.cgi?id=419943)
 * [media-fonts/monaco](https://github.com/init6/init_6/tree/master/media-fonts/monaco) fix for [bug #281939](https://bugs.gentoo.org/show_bug.cgi?id=281939)
 * [media-video/mpv](https://github.com/init6/init_6/tree/master/media-video/mpv) [Video player based on MPlayer/mplayer2](http://mpv.io)
 * [net-irc/irssi](https://github.com/init6/init_6/tree/master/net-irc/irssi) with desktop and icon files
 * [net-wireless/broadcom-sta](https://github.com/init6/init_6/tree/master/net-wireless/broadcom-sta) fix for [bug #484676](https://bugs.gentoo.org/show_bug.cgi?id=484676)
 * [sets/*](https://github.com/init6/init_6/blob/master/sets/README.md)
 * [sys-apps/squashed-portage](https://github.com/init6/init_6/tree/master/sys-apps/squashed-portage) [squashed-portage](https://github.com/init6/squashed-portage) by the old wiki [squashed portage tree](http://web.archive.org/web/20130412155603/http://en.gentoo-wiki.com/wiki/Squashed_Portage_Tree) or [mirror](https://github.com/init6/init_6/wiki/squashed-portage-tree). [project wiki](https://github.com/init6/init_6/wiki/squashed-portage-tree)
 * [sys-firmware/intel-ucode](https://github.com/init6/init_6/tree/master/sys-firmware/intel-ucode) intel IA32 microcode update data
 * [sys-kernel/vanilla-sources](https://github.com/init6/init_6/blob/master/sys-kernel/vanilla-sources/vanilla-sources-9999.ebuild) live 9999 git ebuild
 * [sys-kernel/geek-sources](https://github.com/init6/init_6/tree/master/sys-kernel/geek-sources) [Full geek`s kernel linux sources including](https://github.com/init6/init_6/wiki/geek-sources):
     * **aufs** - [Another Union FS](http://aufs.sourceforge.net)
     * **bfq** - [Budget Fair Queueing Budget I/O Scheduler](http://algo.ing.unimo.it/people/paolo/disk_sched/sources.php)
     * **bld** - [Alternate CPU load distribution technique for Linux kernel scheduler](http://code.google.com/p/bld)
     * **brand** - [Enable Gentoo specific branding.](https://github.com/init6/init_6/wiki/geek-sources)
     * **cjktty** - [CJK support for tty framebuffer vt](https://github.com/Gentoo-zh/linux-cjktty)
     * **ck** - [Enable Con Kolivas' high performance patchset](http://users.on.net/~ckolivas/kernel)
     * **deblob** - [Remove binary blobs from kernel sources to provide libre license compliance](http://linux-libre.fsfla.org/pub/linux-libre)
     * **exfat** - [Samsung’s exFAT fs Linux driver](http://opensource.samsung.com/reception/receptionSub.do?method=search&searchValue=exfat)
     * **fedora** - [Use Fedora kernel patches](http://pkgs.fedoraproject.org/cgit/kernel.git)
     * **gentoo** - [Use Gentoo kernel patches](http://dev.gentoo.org/~mpagano/genpatches)
     * **grsec** - [Use hardened-patchset](http://git.overlays.gentoo.org/gitweb/?p=proj/hardened-patchset.git;a=summary) which includes a [grsecurity patches](http://grsecurity.net)
     * **ice** - [Use TuxOnIce patches](https://github.com/NigelCunningham/tuxonice-kernel)
     * **lqx** - [Use liquorix patches](http://liquorix.net)
     * **mageia** - [Use Mandriva/Mageia patches](http://svnweb.mageia.org/packages/cauldron/kernel)
     * **optimization** - [Kernel patch enables gcc optimizations for additional CPUs](https://github.com/graysky2/kernel_gcc_patch)
     * **pax** - [Use PAX patches](http://pax.grsecurity.net)
     * **pf** - [Use pf-kernel patches](http://pf.natalenko.name)
     * **reiser4** - [Use Reiser4 FS patches](http://sourceforge.net/projects/reiser4)
     * **rh** - [Use Red Hat Enterprise Linux kernel patches](http://www.redhat.com)
     * **rifs** - [RIFS A interactivity favor scheduler](https://code.google.com/p/rifs-scheduler)
     * **rsbac** - [RSBAC (Rule Set Based Access Control) patches](http://www.rsbac.org)
     * **rt** - [Use Ingo Molnar's realtime preempt patches](http://www.kernel.org/pub/linux/kernel/projects/rt)
     * **suse** - [Use OpenSuSE patches](http://kernel.opensuse.org/cgit/kernel-source)
     * **ubuntu** - [Use Ubuntu patches](http://kernel.ubuntu.com/~kernel-ppa)
     * **uksm** - [Use Ultra Kernel Samepage Merging patches](http://kerneldedup.org)
     * **zen** - [Use ZEN kernel patches](https://github.com/damentz/zen-kernel)
     * **zfs** - [The native Linux kernel port of the ZFS filesystem](http://zfsonlinux.org)
 * [sys-kernel/rh-sources](https://github.com/init6/init_6/tree/master/sys-kernel/rh-sources) Full sources including the Red Hat Enterprise Linux sources patchset for the 2.6 kernel tree
 * [sys-libs/core-functions](https://github.com/init6/init_6/tree/master/sys-libs/core-functions) provide alternative for /etc/init.d/functions.sh fix for [bug #373219](https://bugs.gentoo.org/show_bug.cgi?id=373219)
 * [x11-drivers/nouveau-firmware](https://github.com/init6/init_6/tree/master/x11-drivers/nouveau-firmware) fix for [bug #480832](https://bugs.gentoo.org/show_bug.cgi?id=480832)

and many fixes and patches…

Contribute to this overlay
--------------------------

If you want to suggest changes, like new dependencies or new stuff, please send a github pull request with explanation/proof why this is necessary, so we can discuss it. Determine correct behavior and dependencies can be tricky, therefore we'd like to discuss and wait for confirmation of others before adding modifications or new ebuilds.

Release security & signing
--------------------------

All release media will have its Manifest file signed by one of the keys listed on this page.

| Key ID | Key Type | Key Fingerprint | Key Description | Created | Expires | Revoked | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| B9489F0C | 2048-bit DSA/ElGamal | E10F 898F F87E 82A6 928E EC6E 4DFA 96F5 B948 9F0C | Andrey Ovcharov (init_6) <sudormrfhalt@gmail.com> | 2013-08-13 | 2014-02-09 | | |

You will find more in the [GnuPG Gentoo User Guide](http://www.gentoo.org/doc/en/gnupg-user.xml)
