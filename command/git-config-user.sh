#!/usr/bin/env bash

set -eu
set -o pipefail

function self::command() {
	
	local username=${1}
	local email=${2}
	
	git config --global user.name "${username}"
	git config --global user.email ${email}
}

{
	self::command "${@}"
}
