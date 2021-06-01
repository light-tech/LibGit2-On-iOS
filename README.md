LibGit2 on iOS
==============

Similar to our [LLVM-On-iOS project](https://github.com/light-tech/LLVM-On-iOS) and actually thank to the experience from that project, we develop this project to provide scripts and YAML pipeline to build [LibGit2](https://github.com/libgit2/libgit2) and its dependencies (OpenSSL, PCRE and LibSSH2) on Azure DevOps (a.k.a. VSTS) as `XCFramework`s that could be easily embedded in Xcode iOS/Mac Catalyst project.

Building
--------

If you want to build the frameworks on your own machine, simply execute the script
```shell
build-libgit2-framework.sh
```
at the root of this repository.
See [here](https://lightech.visualstudio.com/LibGit2-On-iOS/_build?definitionId=85) for our CI builds on Azure DevOps.

*A tip for Windows user*: Instead of using `swift package compute-checksum`, one can also compute checksum with
```shell
CertUtil -hashfile Clibgit2.xcframework.zip SHA256
```

Integration
-----------

**Method 0**: Interoperate Swift, C/C++ and Objective-C via bridging header as described in our [LLVM-On-iOS project](https://github.com/light-tech/LLVM-On-iOS).

**Method 1**: You can download the [prebuilt XCFramework](https://github.com/light-tech/Clibgit2/releases/tag/v1.1.0), extract and add it directly to your Xcode iOS app project. Then simply
```swift
import Clibgit2
```
and then use the `libgit2` API directly.
The built XCFramework is also released as a Swift Package at [https://github.com/light-tech/Clibgit2](https://github.com/light-tech/Clibgit2).
But [be ready](https://theswiftdev.com/how-to-use-c-libraries-in-swift/) to write not-very-Swift-y Swift code.

**Method 2**: Our recommended way is to use the Swift Package available on the  `spm` branch of [our fork of SwiftGit2](https://github.com/light-tech/SwiftGit2).
`SwiftGit2` takes care of the not-very-Swift-y Swift code.
See the screenshots in our example app below.

Example
-------

To test, you can get [our iOS example app project](https://github.com/light-tech/SwiftGit2-SampleApp) by cloning
```shell
git clone https://github.com/light-tech/SwiftGit2-SampleApp.git
```

Why?
----

The first thing that might have come to your mind is:
> **Why another work on libgit2? Didn't we already have [SwiftGit2](https://github.com/SwiftGit2/SwiftGit2)?**

The reasons:
 * Contrary to the first impression, `SwiftGit2` currently [doesn't compiled for iOS](https://github.com/SwiftGit2/SwiftGit2/issues/190) unless one reverts back to an earlier version. The reason is that `libgit2` now depends on `libpcre` which is only supplied in Xcode's MacOS SDK but not iOS SDK; hence we will run into missing symbols `pcre_*****` when using it in an iOS app.
 * `SwiftGit2` isn't very actively maintained. It still uses the older fat binary (which cannot support MacOS, Mac Catalyst and iPhone Simulator simultaneously since all 3 have the same underlying CPU architecture x86_64 but different ABI) instead of switching to XCFramework.
 * We are only aware of [this blog post](https://www.michaelfcollins3.me/posts/2021/01/build-libgit2-for-ios-and-catalyst/) after doing this work. And the post doesn't build `libpcre` which is necessary for many Git features on iOS.
 * We do not intend to replace `SwiftGit2` but to extract and update its outdated building scripts.

License
-------

This project is public domain. That is, there is no license attached.
Feel free to do what you want with it.
However, **the usage of the result library built by our script is still subjected to `libgit2`, `pcre`, `openssl` and `libssh2` license**.
