#! /usr/local/bin/bash
rsync -av --delete --exclude '.git' _site/ ../balletie.github.io
pushd ../balletie.github.io
git status
read -p "Commit and push? (y/n) " answer
case ${answer:0:1} in
	y|Y)
	git add .
	git commit -m "`date`"
	git push origin master
	;;
	*)
	echo "Publish aborted."
	;;
esac
