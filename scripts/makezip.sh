cd $APPVEYOR_BUILD_FOLDER
ocaml setup.ml -configure
ocaml setup.ml -build
cp vultc.native vultc.exe
7z a $APPVEYOR_BUILD_FOLDER/vult.zip $APPVEYOR_BUILD_FOLDER/vultc.exe $APPVEYOR_BUILD_FOLDER/runtime/vultin.c $APPVEYOR_BUILD_FOLDER/runtime/vultin.h