LibGit2 on iOS
==============

Similar to our [LLVM-On-iOS project](https://github.com/light-tech/LLVM-On-iOS) and actually thank to the experience from that project, we develop this project to provide scripts and YAML pipeline to build [LibGit2](github.com/libgit2/libgit2) and its dependencies (OpenSSL, PCRE and LibSSH2) on Azure DevOps (a.k.a. VSTS) as `XCFramework`s that could be easily embedded in Xcode iOS/Mac Catalyst project.

See [here](https://lightech.visualstudio.com/LibGit2-On-iOS/_build?definitionId=85) for our CI builds on Azure DevOps. (At the moment, we have only built `Libgit2` and `PCRE`.)

If you want to build the frameworks on your own machine, simply execute the script
```shell
    build-libgit2-framework.sh
```
at the root of this repository.

To test, you can get our iOS example project by cloning
```shell
    git clone https://lightech.visualstudio.com/LibGit2-On-iOS/_git/SampleApp
```
