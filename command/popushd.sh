#!/usr/bin/env bash

set -eu
set -o pipefail

function self::command() {
	
	local path=${1}
	
	popd 2>/dev/null || :
	
	pushd "${path}"
}

{
	self::command ${@}
}
