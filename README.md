LibGit2 on iOS
==============

Similar to our [LLVM-On-iOS project](https://github.com/light-tech/LLVM-On-iOS) and actually thank to the experience from that project, we develop this project to provide scripts and YAML pipeline to build [LibGit2](https://github.com/libgit2/libgit2) and its dependencies (OpenSSL, PCRE and LibSSH2) on Azure DevOps (a.k.a. VSTS) as `XCFramework`s that could be easily embedded in Xcode iOS/Mac Catalyst project.

See [here](https://lightech.visualstudio.com/LibGit2-On-iOS/_build?definitionId=85) for our CI builds on Azure DevOps.

If you want to build the frameworks on your own machine, simply execute the script
```shell
build-libgit2-framework.sh
```
at the root of this repository.

To test, you can get our iOS example project by cloning
```shell
git clone https://lightech.visualstudio.com/LibGit2-On-iOS/_git/SampleApp
```

The first thing that might have come to your mind is:
> **Why another work? Didn't we already have [SwiftGit2](https://github.com/SwiftGit2/SwiftGit2)?**

The reasons:
 * Contrary to the first impression, `SwiftGit2` currently [doesn't compiled for iOS](https://github.com/SwiftGit2/SwiftGit2/issues/190) unless one reverts back to an earlier version. The reason is that `libgit2` now depends on `libpcre` which is only supplied in Xcode's MacOS SDK but not iOS SDK; hence we will run into missing symbols `pcre_*****` when using it in an iOS app.
 * `SwiftGit2` isn't very actively maintained. It still uses the older fat binary (which cannot support MacOS, Mac Catalyst and iPhone Simulator simultaneously since all 3 have the same underlying CPU architecture x86_64 but different ABI) instead of switching to XCFramework.
 * We are only aware of [this blog post](https://www.michaelfcollins3.me/posts/2021/01/build-libgit2-for-ios-and-catalyst/) after doing this work. And the post doesn't build `libpcre` which is necessary for many Git features on iOS.
