#!/usr/bin/env bash

set -eu
set -o pipefail

function self::command() {
	
	local branch=${1}
	
	if [[ ${branch} != develop ]]; then
		
		git checkout develop
		git pull origin develop
		git merge ${branch}
		git push origin develop
	fi
	
	if [[ ${branch} != master ]]; then
		
		git checkout master
		git pull origin master
		git merge ${branch}
		git push origin master
	fi
}

{
	self::command ${@}
}
