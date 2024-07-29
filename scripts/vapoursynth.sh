#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Video processing framework with simplicity in mind
# depends on: zimg

# Force 11 deployment target for all homebrew formulas
find $(brew --repository)/Library/Taps -type f -iname *rb -exec sed -i "" $'s/def install/def install\\\n    ENV["MACOSX_DEPLOYMENT_TARGET"] = "11"\\\n/' {} \;          
brew install vapoursynth
rm `brew --prefix vapoursynth`/lib/pkgconfig/*.pc
cp vapoursynth*.pc `brew --prefix vapoursynth`/lib/pkgconfig

cd $DIR
tar -zcvf vapoursynth.tar.xz -C `brew --prefix vapoursynth` .