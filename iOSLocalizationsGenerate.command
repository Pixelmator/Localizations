#!/bin/sh

# Set directory of the script as current directory
cd "$(dirname "$0")"

rm -rf ./iOS/en.lproj

mkdir ./iOS/en.lproj

# generate localizable strings from .m code
find ../../ -type f \( \( -name "*.m" -or -name "*.swift" \) -and -not \( \
-path "*/macOS/*" -or -path "*/Pixelmator Pro/*" -or -path "*/PXTEngine/*" -or -path "*/PTObjectRemoval/*" -or -path "*/PTPaintSelection/*" -or -path "*/*Test App/*" -or -path "*/*Test-App/*" \
-path "*/Gallery/*" -or -path "*/Editors/Arrange/*" -or -path "*/Editors/Distort/*" -or -path "*/Editors/Effects/*" -or -path "*/Editors/Paint/*" -or -path "*/Editors/Selection/*" \
-or -path "*/Editors/Shape/*" -or -path "*/Editors/Style/*" -or -path "*/Editors/Text/*" \
-or -path "*/PDFEngine/*" -or -path "*/PSDEngine/*" -or -path "*/SVGEngine/*" -or -path "*/Bugsnag/*" \
\)  \) -print0 | xargs -0 xcrun extractLocStrings -o iOS/en.lproj

# generate strings from xibs
find ../../ -type f \( \( -name "*.storyboard" -or -name "*.xib" \) -and -not \( \
-path "*/macOS/*" -or -path "*/Pixelmator Pro/*" -or -path "*/PXTEngine/*" -or -path "*/PTObjectRemoval/*" -or -path "*/PTPaintSelection/*" -or -path "*/*Test App/*" -or -path "*/*Test-App/*" \
-or -path "*/PDFEngine/*" -or -path "*/PSDEngine/*" -or -path "*/SVGEngine/*" \
-or -path "*/What's New/*" -or -path "*/PXMKit/*" -or -path "*/Bugsnag/*" -or -path "*/MainMenu*" \
\)  \) | while read XIB; do
    echo "$XIB"
	xibstring=`basename "$XIB"`
	ibtool --export-strings-file ./iOS/en.lproj/"${xibstring%.*}.strings" "$XIB"
done

# genstrings and ibtool produces utf-16 - convert it into utf-8 for git diffs compatibility
find ./iOS/en.lproj/ -name "*.strings" | while read fn; do
	cp "${fn}" "${fn}.bak"
	iconv -f utf-16 -t utf-8 < "${fn}.bak" > "${fn}"
	rm "${fn}.bak"
done

find ./iOS/en.lproj/ \( -name "Blendings.strings" -or -name "EffectNames.strings" -or -name "Preset Manager.strings" -or -name "ToolTips.strings" -or -name "PXTKitPresetManagerViewController.strings" -or -name "Tips.strings" \) | while read fn; do
rm "${fn}"
done

# copy auto generated strings in place
cp -a ../../iOS/Localizations/AutoStrings/. ./iOS/en.lproj/
