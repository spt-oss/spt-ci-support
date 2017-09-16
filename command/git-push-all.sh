#!/usr/bin/env bash

set -eu
set -o pipefail

function self::command() {
	
	local message=${1}
	
	git add --all
	git commit -m "${message}" || return ${?}
	git push origin HEAD
}

{
	self::command "${@}"
}
