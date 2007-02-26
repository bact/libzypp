#
# spec file for package libzypp
#
# Copyright (c) 2006 SUSE LINUX Products GmbH, Nuernberg, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# Please submit bugfixes or comments via http://bugs.opensuse.org/
#

# norootforbuild

Name:           @PACKAGE@
License:        GPL
Group:          System/Packages
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
Autoreqprov:    on
Summary:        Package, Patch, Pattern, and Product Management
Version:        @VERSION@
Release:        0
Source:         @PACKAGE@-@VERSION@.tar.bz2
Prefix:         /usr
Provides:       yast2-packagemanager 
Obsoletes:      yast2-packagemanager
BuildRequires:  cmake
%if %suse_version > 1010
BuildRequires:  sqlite-zmd sqlite-zmd-devel
%else
BuildRequires:  sqlite sqlite-devel
%endif
BuildRequires:  boost-devel curl-devel dejagnu doxygen gcc-c++ graphviz hal-devel libxml2-devel rpm-devel gettext-devel
BuildRequires:	update-desktop-files


%description
Package, Patch, Pattern, and Product Management

Authors:
--------
    Michael Andres <ma@suse.de>
    Jiri Srain <jsrain@suse.cz>
    Stefan Schubert <schubi@suse.de>
    Duncan Mac-Vicar <dmacvicar@suse.de>
    Klaus Kaempf <kkaempf@suse.de>
    Marius Tomaschewski <mt@suse.de>
    Stanislav Visnovsky <visnov@suse.cz>
    Ladislav Slezak <lslezak@suse.cz>

%package devel
Requires:       libzypp
Requires:       libxml2-devel curl-devel openssl-devel rpm-devel glibc-devel zlib-devel
Requires:       bzip2 popt-devel dbus-1-devel glib2-devel hal-devel boost-devel libstdc++-devel
Requires:       cmake
Summary:        Package, Patch, Pattern, and Product Management - developers files
Group:          System/Packages
Provides:       yast2-packagemanager-devel
Obsoletes:      yast2-packagemanager-devel

%description -n libzypp-devel
Package, Patch, Pattern, and Product Management - developers files

Authors:
--------
    Michael Andres <ma@suse.de>
    Jiri Srain <jsrain@suse.cz>
    Stefan Schubert <schubi@suse.de>
    Duncan Mac-Vicar <dmacvicar@suse.de>
    Klaus Kaempf <kkaempf@suse.de>
    Marius Tomaschewski <mt@suse.de>
    Stanislav Visnovsky <visnov@suse.cz>
    Ladislav Slezak <lslezak@suse.cz>

%prep
%setup -q

%build
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=%{prefix} -DCMAKE_SKIP_RPATH=1 ..
CXXFLAGS="$RPM_OPT_FLAGS" \
make %{?jobs:-j %jobs}
make -C doc/autodoc %{?jobs:-j %jobs}
make -C po %{?jobs:-j %jobs} translations

#make check

%install
cd build
make install DESTDIR=$RPM_BUILD_ROOT
make -C doc/autodoc install DESTDIR=$RPM_BUILD_ROOT
%suse_update_desktop_file -G "" -C "" package-manager
make -C po install DESTDIR=$RPM_BUILD_ROOT
# Create filelist with translatins
%{find_lang} zypp


%post
%run_ldconfig

%postun
%run_ldconfig

%clean

%files -f zypp.lang
%defattr(-,root,root)
%{prefix}/lib/zypp
%{_libdir}/libzypp*so.*
%dir %{prefix}/share/zypp
%dir %{prefix}/share/zypp/schema
%{prefix}/share/zypp/schema/*
%{prefix}/share/pixmaps/package-manager-icon.png
%{prefix}/share/applications/package-manager.desktop
%{prefix}/bin/package-manager
%{prefix}/bin/package-manager-su

%files devel
%defattr(-,root,root)
%{_libdir}/libzypp.so
#%dir %{_libdir}/libzypp.la
%{_docdir}/%{name}
%dir %{prefix}/include/zypp
%{prefix}/include/zypp/*
%{prefix}/share/cmake/Modules/FindLibzypp.cmake
%{_libdir}/pkgconfig/libzypp.pc

%changelog -n libzypp
* Wed Mar 29 2006 - visnov@suse.de
- added support for external scripts to metadata (#159928) (jsrain)
- fixed handling of Language resolvables (ma)
- fix leak in rpmdb (dmacvicar)
- added softlock for autoyast (#159466) (ma)
- Fixed exceptions in doGetFileCopy() to show full url
  including the file instead of just the media base url. (mt)
- Provide Language::summary (ma)
- check patterns and selections file exist
  before veryfing them (#161300) (dmacvicar)
- added YUM metadata checksum computation (jsrain)
- added interface to patch of a message (jsrain)
- r2734
* Mon Mar 27 2006 - jsrain@suse.de
- added support for external scripts to metadata (#159928)
- r2709
* Sat Mar 25 2006 - jsrain@suse.de
- report separate exception when trying to start source cache again to
  suppress incorrect error message in XEN installation
- r2682
* Fri Mar 24 2006 - schubi@suse.de
- Implement inter process locking in zypp.
- Added No medium found output
- splitting modaliases in supplements TOO
- parse also the available signing keys
* Fri Mar 24 2006 - visnov@suse.cz
- release all media when removing source (#159754) (visnov)
- more testsuites (schubi)
- updated translations (schubi)
- added MediaNotEjectedException (mt)
- rev 2652
* Thu Mar 23 2006 - dmacvicar@suse.de
- fix patches descriptions (dmacvicar)
- fix source serialization (dmacvicar)
- metadata for kernel test (schubi)
- Arch tests updated (ma)
- classify NULL Ptr as unique (ma)
- Added host check, because file Url allows it now. (mt)
- prepare modalias fix (#159766) (ma)
- Provide iterator based access to SourceManager data. (ma)
- Fixed "file:" Url scheme config to allow relative paths; (mt)
  RFC1738 says, it may contain a hostname as well...
- revision 2633
* Wed Mar 22 2006 - visnov@suse.cz
- pkg-config support (mvidner)
- close all medias when destructing MediaSet (jsrain)
- rev 2622
* Wed Mar 22 2006 - dmacvicar@suse.de
- Bug 159976 - build 804: Adding AddOn CD via ftp gives error (dmacvicar)
- Message callback implemented to show patch messages (visnov)
- Bug 159696 (schubi)
- provide transform_iterators to iterate over a maps keys or values (ma)
- added 'bool Arch::empty() const' test for an empty Arch string (ma)
- added script and message installation (jsrain)
- chooses the 'right' kernel now (kkaempf)
- Use noarch if no arch is specified in patches (dmacvicar)
- rev 2611
* Tue Mar 21 2006 - mvidner@suse.cz
- Added some debug output including the access id (mt)
- Bug #154326: Enabled FORCE_RELEASE_FOREIGN flag causing
  release with eject=true on attached media, to umount
  other mounts as well. (mt)
- 159483 - solver does not blame missing dependency (schubi)
- Added a variant of MediaHandler::forceRelaseAllMedia (ma)
- Fixed MediaCD::forceEject() to handle DELAYED_VERIFY
  and use forceRelaseAllMedia if FORCE_RELEASE_FOREIGN=1 (ma)
- fixed ZYPP_RETHROW (#156430) (ma)
- patch for #156114 (visnov)
- fixed container.erase loops (ma)
- Fixed to reset desired (cached) flag before the action (mt)
- Removed return in forceRelaseAllMedia (void function) (mt)
- Parse nonexisting architecture to noarch so patches dont get
  filtered by the pool (dmacvicar)
- 159512 - yast2-qt does not show label of to be installed products
  anymore (dmacvicar)
- 159765 - Hidden patterns still visible (dmacvicar)
- Use noarch if no arch is specified. (dmacvicar)
- r2594
* Tue Mar 21 2006 - visnov@suse.de
- properly report error for media change callback
- rev 2579
* Mon Mar 20 2006 - ma@suse.de
- fixed memory leak in XMLNodeIterator (#157474)
- disabled storing filelist (YUMFileListParser) and changelog (YUMOtherParser)
- Renamed private MediaManager::forceMediaRelease
  function to forceReleaseShared (more exact name)
- Implemented forceRelaseAllMedia() that can be
  used to release also foreign (user) mounts.
- Added use of forceRelaseAllMedia for CD/DVDs
  if FORCE_RELEASE_FOREIGN is 1 (default 0)
- little cleanup of the checkAttached function
- r2578
* Mon Mar 20 2006 - mvidner@suse.cz
- don't try to attach without exception handling (#158620)
- fix descriptions, as a new tag Des for selections exists now.
- fix #157683: failure after adding add-on product to install
  sources
- added more files for translation
- resolve-dependencies.cc: establish pool
- parse-metadata.cc: catch bad URL
- set zmdid for atoms
- r2574
* Sun Mar 19 2006 - kkaempf@suse.de
- fix testsuite.
- provide edition and architecture for all kinds of yum
  resolvables.
- fix ResStatus output.
- establish atoms correctly.
- treat requires to unneeded resolvables as fulfilled.
- rev 2559
* Sun Mar 19 2006 - kkaempf@suse.de
- fix the build
- only consider best architecture/version (#157594)
- prefer providers which supplement/enhance installed or
  to-be-installed packages (fixes the tpctl-kmp issue)
- rev 2546
* Sat Mar 18 2006 - kkaempf@suse.de
- provide more filters for pkg-bindings (#158602)
- add SystemResObject to provide system (modalias, hal, ...)
  capabilities.
- handle this during resolving.
- make the modalias and hal capability match the SystemResObject
  by default, thereyby triggering a modalias (resp. hal)
  evaluation.
- xmlstore: decouple target store from YUM schema.
- clean up moving of hal() and modalias() from provides to
  supplements in ResolvableImpl.
- add PatchContents() for UI.
- handle Edition::noedition as empty string.
- r2537
* Tue Mar 14 2006 - jsrain@suse.de
- releasing all medias when asking for CD (#156981)
- r2471
* Tue Mar 14 2006 - mvidner@suse.cz
- ResStatus::resetTransact must return a value.
- Fixed random build failures in LanguageCode.cc.
  (Rewrote the CodeMaps constructor so that gcc does not
  optimize a 500-statement basic block.)
- Fix constructions of patch objects. Actually insert atoms in atoms
  list. Insert atoms for package even if the package does not exists
  in the source. Fixes #157628 (dmacvicar).
- Fixed license reading from susetags, #151834 (dmacvicar).
- r2468
* Tue Mar 14 2006 - mvidner@suse.cz
- added ResStatus::resetTransact (ma)
- bugfix for #156439 (schubi)
- Added Source_Ref::setAlias (#154913).
- Do not assume there is a product file when scanning for products
  (visnov)
- function to disable all sources in the persistent store (visnov)
- dependency errors go to stdout, not stderr; output resolver info
  directly to stderr (kkaempf)
- rev 2464
* Tue Mar 14 2006 - kkaempf@suse.de
- fix merging of resolver info (needed for #157684).
- errors are also important in ResolverInfo.
- improve debug output in ResolverContext.
- rev 2455
* Mon Mar 13 2006 - jsrain@suse.de
- delete RPMs downloaded via HTTP/FTP after installnig them
  (#157011)
- fixed product registration (reverted autorefresh patch) (#157566)
* Mon Mar 13 2006 - kkaempf@suse.de
- if root!="/", always prefer the upgrade candidate (#155472)
- implement license confirmed api for UI.
- prefer architecture over version in distribution upgrade
  (#157501)
- clean up media handling.
- rev 2448
* Sun Mar 12 2006 - kkaempf@suse.de
- init Modalias properly.
- fix warnings in testcases.
- rev 2432
* Sat Mar 11 2006 - kkaempf@suse.de
- drop libjpeg-devel and sqlite-devel from build requires.
* Sat Mar 11 2006 - kkaempf@suse.de
- implement 'modalias()' capability (#157406)
- make dependencies consistent, its 'freshens'.
- cope with user umounts of devices.
- add debug to SourceManager.
- rev 2418
* Fri Mar 10 2006 - kkaempf@suse.de
- allow version downgrade during distribution upgrade if the
  newer package is coming from a trusted vendor (#155472)
- implement locale fallback
- 'freshen' -> 'freshens' in schema definitions to make it
  consistent with all other dependency definitions.
- better error reporting for .pat and .sel files.
- rule out packages from dependency resolutions which are
  de-selected by user (#155368)
- use locale fallbacks in package translations.
- refresh source when re-enabling it.
- rev 2406
* Tue Mar 07 2006 - kkaempf@suse.de
- split of libzypp-zmd-backend subpackage as a stand-alone
  leaf package.
- encapsulate bool test for Source_Ref better.
- fixed stack overflow (ma).
- make testsuite build again.
- rev 2346
* Tue Mar 07 2006 - kkaempf@suse.de
- fixed URL rewriting for CD2 and following (#154762)
- fixed ResPoolProxy diffState (for proper ok/cancel support
  in UI)
- added special exception class for aborting installation
  (#154936)
- only auto-change directories if they end in CDn or DVDn.
- rev 2320.
* Tue Mar 07 2006 - kkaempf@suse.de
- silently ignore multiple installs of the same package.
- fix disk usage for installs and uninstalls.
- rev 2308
* Mon Mar 06 2006 - kkaempf@suse.de
- zmd-backend: filter out incompatible architectures from
  repository.
- rev 2298
* Mon Mar 06 2006 - kkaempf@suse.de
- sync libzypp media data with mtab.
- improve resolver error and solution reports.
- fix source cache reading (#155459).
- default cached sources to enabled (#155459).
- let each source provide public keys.
- rev 2297
* Sun Mar 05 2006 - kkaempf@suse.de
- only write by-sovler transactions back (#154976)
- rev 2278
* Sat Mar 04 2006 - kkaempf@suse.de
- release last used source at end of commit (#155002)
- rev 2277
* Fri Mar 03 2006 - kkaempf@suse.de
- cope with NULL values in zmd catalogs table (#153584)
- set YAST_IS_RUNNING in transact zmd helper (#154820)
- run SuSEconfig after transact zmd helper (#154820)
- add softTransact to honor user vs. soft requirements (#154650)
- honor all build keys provided by a package source.
- add source metadata refresh.
- add progress callbacks to zmd helpers.
- rev 2276
* Thu Mar 02 2006 - kkaempf@suse.de
- include .diffs into main source.
- catch exception when ejecting media which was unmounted externally
  (#154697).
- init source in zmd-backend correctly (#154667)
- implement disk usage info for YaST.
- clean up XML schema files.
- catch CPUs identifying as 'i686' but being 'i586'.
- allow definition of preferred attach (mount) point for media.
- make resolver results more readable.
- use language fallbacks if none of multiple language providers
  matches.
- get rid of ignoring wrong arch in resolver, having the wrong
  architecture is prevented by other means.
- prepare for translations in exceptions.
- fix 'abort does not abort'
- implement 'flag' I/O in target cache backend.
- skip incompatibles architectures in packages.<lang>
- rev 2228
* Thu Mar 02 2006 - kkaempf@suse.de
- dont even provide src/nosrc from the source.
- rev 2169 + diffs
* Wed Mar 01 2006 - kkaempf@suse.de
- Initialize commit result (#154409)
- release media if its wrong (#154326)
- dont copy src/nosrc packages to the pool (#154627)
- reduce XML logging.
- rev 2169 + diffs
* Tue Feb 28 2006 - kkaempf@suse.de
- fix path of .po files (#154074).
- parse the correct package.<lang> file (kinda #154074).
- complain about bad "=Sel:" or "=Pat:" lines (#153065).
- reattach all released medias.
- raise exception instead of abort() on XML errors (#154104).
- update translations.
- PathInfo: implemented a copy_dir_content (variant of copy_dir)
  and is_empty_dir utility function
- rev 2169
* Tue Feb 28 2006 - kkaempf@suse.de
- check freshens and supplements for packages (#154074).
- only complain about incomplete installed resolvables,
  if they are uninstalled, schedule them for installation.
  (#154074)
- add testcases for locale() provides.
- add lang_country -> lang fallback.
- have locale(parent:...) deps match any provides of 'parent'
  also when uninstalling a package.
- rev 2148
* Tue Feb 28 2006 - kkaempf@suse.de
- change the locale(...) separator to ";" (#153791)
- complete "find-files" of zmd-backend.
- rev 2140
* Tue Feb 28 2006 - visnov@suse.de
- avoid attaching media when initializing source
- rev 2139
* Mon Feb 27 2006 - kkaempf@suse.de
- warn about misspelled 'locale(...)' provides
- add testcases
- rev 2134
* Mon Feb 27 2006 - kkaempf@suse.de
- fix the build
- rev 2129
* Mon Feb 27 2006 - kkaempf@suse.de
- provide available locales to application (#153583)
- honor 'requestedLocales' (language dependant packages)
- honor release requests for all holders of a device.
- silently re-attach after a forced release.
- solver improvements.
- handle source caches.
- proper logging in zmd backend helpers.
- rev 2127
* Mon Feb 27 2006 - kkaempf@suse.de
- upgrade always to best version and arch (#153577)
- reset 'transact' state for obsoleted packages (#153578)
- translation updates
- rev 2113
* Mon Feb 27 2006 - kkaempf@suse.de
- add support for 'local' .rpm packages to zmd-backend.
- rev 2101
* Sun Feb 26 2006 - kkaempf@suse.de
- fix build of zmd/backend.
- actually fill 'files' table in package-files.
- rev 2094
* Sun Feb 26 2006 - kkaempf@suse.de
- improve testcases.
- add 'setPossibleLocales()' to ZYpp, this defines the set
  of possible locales to choose from (#153583)
- provide LanguageImpl and create 'Language' resolvables for
  each 'possible' locale.
- fix YUM parsing of patches, insert 'atoms' to link patches
  with packages.
- replace gzstream/ with own, existing implementation.
- honor locks in solver (#150231)
- sync pool with target after commit() properly (#150565, #153066)
- new zmd helper 'package-files'
- rev 2093
* Thu Feb 23 2006 - kkaempf@suse.de
- prevent multiple initializations of the target (#153124)
- implement 'loopback mounted ISO images'
- retain old package sources on upgrade.
- support compressed .xml files in 'repodata' type repositories.
- rev 2025
* Thu Feb 23 2006 - kkaempf@suse.de
- parse locale(...) provides and construct correct dependencies.
* Thu Feb 23 2006 - kkaempf@suse.de
- always upgrade to candidate (#152760).
- fix typo in package sorting.
- prepare handling of locale provides.
- rev 1995
* Thu Feb 23 2006 - kkaempf@suse.de
- sort src/nosrc package to right list during commit.
- revert installtime/buildtime in susetags parser (#152760)
- rev 1990
* Thu Feb 23 2006 - kkaempf@suse.de
- reset state after successful commit (#153030)
- run "rpm -e" always with "--nodeps" (#153026)
- provide separate resolvable kind for src packages.
- extend status field for LOCK and LICENSE.
- add sameState()/diffState() for UI.
- provide 'best' candidate for UI.
- set 60 sec timeout for curl access.
- don't cross-compare solver results, takes too much time.
- provide sizes of installed packages.
- extend REQUIRES semantics in content file.
- add "parse-metadata" helper to zmd-backend.
- rev 1987
* Wed Feb 22 2006 - kkaempf@suse.de
- provide complete disk usage data (#152761)
- include upgrade flag when copying solver solution
  back to pool (#152717)
- rev 1959
* Wed Feb 22 2006 - kkaempf@suse.de
- don't insert incompatible architectures to the pool (#151933)
- don't accept incompatible architectures from a repository
  (#151933)
- separate rpm log (#151431).
- allow extended product requires.
- rev 1954
* Tue Feb 21 2006 - kkaempf@suse.de
- provide the XML schema files in the main package. (#152593)
* Tue Feb 21 2006 - kkaempf@suse.de
- provide arch compat handling.
- implement data upload to zmd.
- fix source metadata caching on target.
- add 'supplements' dependencies to 'yum' parser.
- provide user agent identification to curl calls.
- move resolver branches (multiple alternatives) back in queue
  (resolve known things first, then the unknown ones).
- clean up 'packages' parser.
- rev 1947
* Tue Feb 21 2006 - kkaempf@suse.de
- improve media mount/umount interface
- prepare class ArchCompat for proper architecture ordering
  and compatibility handling.
- add returns to dummy functions in DbAccess.
- rev 1913
* Mon Feb 20 2006 - kkaempf@suse.de
- don't explictly delete to-be-upgraded packages.
- finish query-system, resolve-dependencies, and transact for
  libzypp-zmd-backend.
- provide Pattern::category.
- move system architecture to toplevel.
- make target store pathname settable.
- speed up rpmdb reading by properly filtering unwanted file
  provides.
- rev 1905
* Sun Feb 19 2006 - kkaempf@suse.de
- new translations.
- proofread texts.
- when comparing solutions, prefer higher versions.
- provide generic 'SafeBool' for bool conversions.
- add PtrTypes testsuites.
- rev 1876
* Fri Feb 17 2006 - kkaempf@suse.de
- integrate all diffs
- move Target::commit to toplevel API
- generalize dependency iterators and hash dependency
  information in pool (for speedup)
- add 'supplements' as dependency
- make more pattern attributes available
- drop "smbfs" in favour of "cifs" (#151476)
- add metadata cache to sources (Beta4 bug)
- run "rpm -e"  with name-version-release
- fix update conflicts
- rev 1864
* Thu Feb 16 2006 - kkaempf@suse.de
- fix-mediachange.diff: dont skip CD but retry after media change
- cd-eject-button.diff: fix CD url so YaST recognizes it and shows
  'eject' button
- release-forced-eject-no-ptrfix.diff: fix refcounting in ptrs
  so media handle gets actually released and media unmounted.
* Thu Feb 16 2006 - kkaempf@suse.de
- implement arch scoring
- prefer better arch (#151427)
- transitive depedencies of weak requirements are non-weak
  (#151446)
- rev 1778 + diff
* Wed Feb 15 2006 - kkaempf@suse.de
- ignore self and to-be-updated conflicts (#150844)
- fix enable of target store (for non-packages)
- rev 1778
* Wed Feb 15 2006 - kkaempf@suse.de
- fix "cd:" url (#151121)
- provide location() in public Package api
- allow running distribution upgrade in testmode
- extend HAL interface
- rev 1762
* Wed Feb 15 2006 - kkaempf@suse.de
- pass normal and locale packages from selections correctly.
- its "baseconf" for base selections.
- Make 'ZYpp' an obvious singleton.
- provide releasenotesUrl.
- dont continue upgrade without target.
- implement 'fake' hal for testing.
- fix package sizes.
- more solver testcases.
- rev 1754
* Tue Feb 14 2006 - kkaempf@suse.de
- extend requires of libzypp-devel
- provide package sizes for UI
- provide more UI helpers
- implement Product and related functions
- fix split provides in distribution upgrade
- provide locale information to system
- ask HAL for available devices
- reduce debug information in solver
- filter architectures in source, not in solver
- rev 1743
* Tue Feb 14 2006 - visnov@suse.de
- disable another testsuite for now
- fetch the default locale from environment
- support user-defined formatting of log
- rev 1710
* Mon Feb 13 2006 - visnov@suse.de
- providing basic product information from susetags source
- public API for preferred language
- implemented redirect of logging (#149001)
- report start/finish of source data parsing (#150211)
- store/restore source aliases properly (#150256)
- disable a lot of debug logging to speed up solver
- properly rewrite URL for CDn directory layouts (#149870)
- rev 1706
* Sun Feb 12 2006 - kkaempf@suse.de
- add save/restore state to facilitate UI 'cancel'
- enable target/store
- add 'forceResolve' call and flag to resolver to switch between
  task-oriented ZMD and interactive YaST behaviour.
- Fix resolver problem solution texts.
- improve solver problem solution offerings.
- fix media access handling to better support multiple
  requestors to single media.
- move the media number checking to the source (media requestor)
  which knows how to verify the correct media.
- Fix CD ordering (#149871), adding testcases.
- Move 'PoolItemList' and 'PoolItemSet' typedefs inside classes.
- Add selections to testcases.
- rev 1673
* Sat Feb 11 2006 - kukuk@suse.de
- Fix missing return in Source.cc:124
* Fri Feb 10 2006 - kkaempf@suse.de
- cope with empty arch field in selections
- enable dummy "enableStorage" function
- rev 1610-branch
* Fri Feb 10 2006 - kkaempf@suse.de
- fix random data return in Source.cc
- rev 1610
* Fri Feb 10 2006 - kkaempf@suse.de
- adapt zmd-backend to SourceImpl API change
- rev 1608
* Fri Feb 10 2006 - kkaempf@suse.de
- fix the packages parser bug. Now all packages are parsed
  including (english) translations.
  source/susetags is back to svn head.
- rev 1600
* Fri Feb 10 2006 - kkaempf@suse.de
- fix off-by-one bug in bitfield handling
- revert source/susetags to rev 1411
- rev 1586
* Thu Feb 09 2006 - kkaempf@suse.de
- dont prereq-sort non-packages
- rev 1584
* Thu Feb 09 2006 - kkaempf@suse.de
- rev 1582
* Thu Feb 09 2006 - kkaempf@suse.de
- update to rev 1543
* Thu Feb 09 2006 - ro@suse.de
- require hal-devel in libzypp-devel
- re-merge fixes (RPM_OPT_FLAGS)
* Wed Feb 08 2006 - kkaempf@suse.de
- make solver behaviour a bit more interactive
- rev 1537
* Wed Feb 08 2006 - schwab@suse.de
- Fix syntax error in configure script.
- Use RPM_OPT_FLAGS.
* Wed Feb 08 2006 - kkaempf@suse.de
- update for qt ui integration
- rev 1504
* Tue Feb 07 2006 - kkaempf@suse.de
- split off libzypp-zmd-backend
- rev 1466
* Tue Feb 07 2006 - kkaempf@suse.de
- another update to svn
* Mon Feb 06 2006 - kkaempf@suse.de
- finish rpm callbacks
- finish UI API
- fix state change resolver<->pool
- zmd backend stuff
- speed up tag file parsing
- rev 1405
* Mon Feb 06 2006 - schubi@suse.de
- disabling failing tests of s390 and ppc
* Mon Feb 06 2006 - schubi@suse.de
- Snapshoot rev 1367
* Mon Feb 06 2006 - kkaempf@suse.de
- use hashes for pool
- rev 1343
* Fri Feb 03 2006 - schubi@suse.de
- removed Obsoletes:    yast2-packagemanager
* Fri Feb 03 2006 - schubi@suse.de
- Snapshoot 3 Feb 2005 (11:30)
* Thu Feb 02 2006 - schubi@suse.de
- Snapshoot 2 Feb 2005 (14:00)
* Thu Feb 02 2006 - schubi@suse.de
- Snapshoot 2 Feb 2005 ( integrating YaST )
* Wed Jan 25 2006 - mls@suse.de
- converted neededforbuild to BuildRequires
* Sat Jan 14 2006 - kkaempf@suse.de
- Initial version
