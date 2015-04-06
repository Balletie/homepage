#! /usr/local/bin/bash -x
rsync -av --delete --exclude-from '.syncignore' _site/ ../balletie.github.io
pushd ../balletie.github.io
git status
set +x
if [ -z "$1" ]
	then
	message="`date`"
else
	message="$1"
fi
echo "Committing with message \"$message\""
read -p "Commit and push? (y/n) " answer
case ${answer:0:1} in
	y|Y)
set -x
	git add .
	git commit -m $message
	git push origin master
	;;
	*)
	echo "Publish aborted."
	;;
esac
