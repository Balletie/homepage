#! /usr/local/bin/bash

function print_info {
	echo -e "[\e[0;33minfo\e[0m] $1"
}

#./site check || exit 1;
print_info "Showing local changes."
git diff `git status -s | grep .*.md | cut -b4-`
print_info "Syncing files to site."
rsync -av --delete --exclude-from '.syncignore' _site/ ../balletie.github.io
pushd ../balletie.github.io
print_info "Showing resulting change in site"
git status -s
if [ -z "$1" ]
	then
	message="`date`"
else
	message="$1"
fi
print_info "Committing with message \"$message\""
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
