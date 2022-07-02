LibGit2 on iOS
==============

Similar to our [LLVM-On-iOS project](https://github.com/light-tech/LLVM-On-iOS) and actually thank to the experience from that project, we develop this project to provide scripts and YAML pipeline to build [LibGit2](https://github.com/libgit2/libgit2) and its dependencies (OpenSSL, PCRE and LibSSH2) on Azure DevOps (a.k.a. VSTS) as `XCFramework`s that could be easily embedded in Xcode iOS/Mac Catalyst project.

Building
--------

If you want to build the frameworks on your own machine, simply execute the script
```shell
build-libgit2-framework.sh
```
at the root of this repository. But see [here](https://github.com/light-tech/LLVM-On-iOS#the-tools-we-needs) first for the tools preparation.

Our releases are built with [GitHub Actions](https://github.com/light-tech/LibGit2-On-iOS/actions).

How To Use
----------

**Method 0**: Interoperate Swift, C/C++ and Objective-C via bridging header as described in our [LLVM-On-iOS project](https://github.com/light-tech/LLVM-On-iOS). You can use `libgit2.xcframework` if you want to use our [prebuilt](https://github.com/light-tech/LibGit2-On-iOS/releases).

This method is crystallized in [our new Swift package MiniGit](https://github.com/light-tech/MiniGit) and is **our recommended way**.

See the screenshots in our example app below.

**Method 1**: You can download our [prebuilt XCFramework](https://github.com/light-tech/LibGit2-On-iOS/releases), extract and add it directly to your Xcode iOS app project. For this method, you will need the `Clibgit2.xcframework` which exposes the module to Swift. Then simply
```swift
import Clibgit2
```
and then use the `libgit2` **C API** directly.
The built XCFramework is also released as a Swift Package at [https://github.com/light-tech/Clibgit2](https://github.com/light-tech/Clibgit2).
But since libgit2 is a C library, [be ready](https://theswiftdev.com/how-to-use-c-libraries-in-swift/) to write some not-very-Swift-y Swift code. See also the [official documentation](https://github.com/apple/swift/blob/main/docs/HowSwiftImportsCAPIs.md).

**Method 2**: You can use the Swift Package available on the  `spm` branch of [our fork of SwiftGit2](https://github.com/light-tech/SwiftGit2).
Basically, `SwiftGit2` takes care of the not-very-Swift-y Swift code in method 1.
However, it is missing a lot of Git features such as `git push` so if you need them, you have to write those not-very-Swift-y Swift code yourself as in method 1.
Thus, we now recommend method 0 as it is best to write C code in C and not Swift's emulation.

Known Issues
------------

Our prebuilt XCFrameworks can only be used on Intel Macs when building for iOS simulator or Mac Catalyst.

Example
-------

To test, you can get [our iOS example app project](https://github.com/light-tech/MiniGit-SampleApp) by cloning
```shell
git clone https://github.com/light-tech/MiniGit-SampleApp.git
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
