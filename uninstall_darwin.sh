#!/bin/bash

destdir=$1

if [ -z "$destdir" ]; then
   export destdir=/tmp/skychart
fi

echo Uninstall skychart from $destdir

rm -fv $destdir/skychart.app/Contents/MacOS/skychart
rm -fv $destdir/varobs.app/Contents/MacOS/varobs
rm -fv $destdir/libgetdss.dylib
rm -fv $destdir/libplan404.dylib

rm -rf $destdir/skychart.app 
rm -rf $destdir/varobs.app
