#!/bin/sh

cd -- "$(dirname "$BASH_SOURCE")"

rm -rf ./macOS/en.lproj

mkdir ./macOS/en.lproj

# generate localizable strings from .m code
find ../../macOS ../ -type f \( -name "*.m" -or -name "*.swift" \) -print0 | xargs -0 xcrun extractLocStrings -o macOS/en.lproj

# generate strings from xibs
find ../../macOS/Base.lproj/ ../../macOS/Pixelmator\ Pro/Base.lproj/ ../../macOS/Photomator/Base.lproj/ -type f \( -name "*.storyboard" -or -name "*.xib" \) | while read XIB; do
	xibstring=`basename "$XIB"`
	ibtool --export-strings-file ./macOS/en.lproj/"${xibstring%.*}.strings" "$XIB"
done

# remove empty string files
find ./macOS/en.lproj/ -type f '!' -exec grep -q "=" {} \; -exec rm {} \;

# genstrings and ibtool produces utf-16 - convert it into utf-8 for git diffs compatibility
find ./macOS/en.lproj/ -name "*.strings" | while read fn; do
	cp "${fn}" "${fn}.bak"
	iconv -f utf-16 -t utf-8 < "${fn}.bak" > "${fn}"
	rm "${fn}.bak"
done

# copy auto generated strings in place
cp -a ../../macOS/Localizations/AutoStrings/. ./macOS/en.lproj/

#generate template collection and preset title strings

templateIntermediateString=./macOS/en.lproj/Templates_intermediate.strings
find ../../macOS/Pixelmator\ Pro/Templates/ -name "*.plist" | while read fn; do
    value=$(/usr/libexec/PlistBuddy -c 'print ":templateTitle"' "$fn" 2>/dev/null || printf '0')
    if [ "$value" == '0' ]; then # OK
        echo "Failed to find key templateTitle in plist file $fn"
    else
        echo "\"$value\" = \"$value\";\n" >> $templateIntermediateString
    fi

    value=$(/usr/libexec/PlistBuddy -c 'print ":collectionTitle"' "$fn" 2>/dev/null || printf '0')
    if [ "$value" == '0' ]; then # OK
        echo "Failed to find key collectionTitle in plist file $fn"
    else
        echo "\"$value\" = \"$value\";\n" >> $templateIntermediateString
    fi
done

find ../../macOS/Pixelmator\ Pro/Templates/Brand\ Templates/ -mindepth 1 -maxdepth 1 -type d | while read entry; do
    DirName=$(basename "$entry")
    validName="${DirName##*-}"
    echo "\"$validName\" = \"$validName\";\n" >> $templateIntermediateString
done

templateString=./macOS/en.lproj/Templates.strings
resultStrings=$(sort "$templateIntermediateString" | uniq)
printf "$resultStrings" >> $templateString
rm "$templateIntermediateString"

#remove unlocalized strings for now
rm ./macOS/en.lproj/PhotoTips.strings
