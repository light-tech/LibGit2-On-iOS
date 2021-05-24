FRAMEWORKS=(libpcre openssl libssh2 libgit2)
FRAMEWORKS_RELEASE_URL=https://github.com/light-tech/LibGit2-On-iOS/releases/download/v1.1.0
for framework in ${FRAMEWORKS[@]}; do
	wget $FRAMEWORKS_RELEASE_URL/$framework.xcframework.zip
	swift package compute-checksum $framework.xcframework.zip
done
