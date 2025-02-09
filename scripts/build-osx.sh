#! /bin/bash

source ./environment-osx.sh
brew update
mkdir -p plugins || exit 1
bash ./build-common-osx.sh || exit 1
bash ./${TARGET_PLUGIN}/build-osx.sh || exit 1
#exit

rm -rf plugins-fixed
#curl -L https://download.gimp.org/mirror/pub/gimp/v2.10/osx/gimp-2.10.6-x86_64.dmg -O || exit 1
#hdiutil attach gimp-2.10.6-x86_64.dmg >& attach.log || exit 1
curl -L https://download.gimp.org/mirror/pub/gimp/v2.10/osx/gimp-2.10.8-x86_64-1.dmg -O || exit 1
hdiutil attach gimp-2.10.8-x86_64-1.dmg >& attach.log || exit 1
export MOUNT_POINT=$(cat attach.log | tr "\t" "\n" | tail -n 1)
export GIMP_BUNDLE="$(find "$MOUNT_POINT" -depth 1 -name "*.app" | tail -n 1)"
rm -f /tmp/gimp.app
ln -s "$GIMP_BUNDLE" /tmp/gimp.app || exit 1
ls -l /tmp/gimp.app/
bash ./fix-dylib.sh ${TARGET_PLUGIN} "$(basename "$GIMP_BUNDLE")" || exit 1
if [ -e "${TARGET_PLUGIN}/fix-dylib.sh" ]; then
	bash "${TARGET_PLUGIN}/fix-dylib.sh" ${TARGET_PLUGIN} "$(basename "$GIMP_BUNDLE")"
fi
ls plugins-fixed || exit 1
cd plugins-fixed || exit 1
rm -f *-orig
tar czf ../${TARGET_PLUGIN}-Gimp-2.10-osx.tgz ??* || exit 1
cd ..
cp /tmp/commit-${TARGET_PLUGIN}-new.hash ${TARGET_PLUGIN}-Gimp-2.10-osx.hash

wget -c https://github.com/aferrero2707/uploadtool/raw/master/upload_rotate.sh
bash  ./upload_rotate.sh "continuous" *.tgz >& /dev/null
bash  ./upload_rotate.sh "continuous" *.hash >& /dev/null

