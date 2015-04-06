#! /usr/local/bin/bash

function print_error {
	echo -e "[\e[0;31merror\e[0m] $1"
}

function print_info {
	echo -e "[\e[0;33minfo\e[0m] $1"
}

relevant_files=$(git status -s \
               | grep -E 'templates|css|posts|albums|images|(.*.md)' \
               | cut -b4-)
[ -z $relevant_files ] && { print_info "Nothing to commit, abort."; exit 0; }

# Build and check the site.
make build || { print_error "Build failure."; exit 1; }
#./site check || { print_error "Site is broken."; exit 1; }

print_info "Showing local changes."
git diff $relevant_files

print_info "Syncing files to site."
rsync -av --delete --exclude-from '.syncignore' _site/ ../balletie.github.io

pushd ../balletie.github.io

print_info "Showing resulting change in site."
git status
if [ -z "$1" ]
	then
	message="`date`"
else
	message="$1"
fi

print_info "To be committed:\n$relevant_files"

print_info "Committing with message \"$message\""
read -p "Commit and push? (y/n) " answer

case ${answer:0:1} in
	y|Y)
set -x
	git add .
	git commit -m "$message"
	git push origin master
	popd
	git add $relevant_files # Only push the relevant files.
	git commit -m "$message"
	git push origin master
	;;
	*)
	print_info "Publish aborted. Resetting site."
	git reset --hard HEAD
	popd
	;;
esac
