#!/usr/bin/env bash

set -eu
set -o pipefail

function self::install() {
	
	local version=${1}
	
	curl -fsSL https://github.com/circleci/docker/raw/docker-1.10.0/install-circleci-docker.sh | \
		sed 's/curl -L /curl -fsSL /g' | \
		bash -s -- ${version}
}

{
	[[ -v CIRCLECI ]] || exit ${?}
	
	self::install ${@}
	
	docker version 2>/dev/null || :
}
