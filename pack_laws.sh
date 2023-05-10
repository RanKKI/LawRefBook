zip -r laws.zip Laws/* -x "Laws/scripts/*" "Laws/.github/*" "**/.*" > /dev/zero
shasum -a 1 -b laws.zip | awk -F" " '{printf "%s", $1}'> laws.zip.sha1