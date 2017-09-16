#!/usr/bin/env bash

set -eu
set -o pipefail

function self::command() {
	
	local version=${1}
	local status=0
	
	mvn release:prepare --batch-mode -DreleaseVersion=${version} -DskipTests || status=${?}
	
	if [ ${status} != 0 ]; then
		
		mvn release:rollback
		
		return ${status}
	fi
	
	mvn release:perform --batch-mode
}

{
	self::command ${@}
}
