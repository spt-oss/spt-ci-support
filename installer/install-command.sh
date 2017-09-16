#!/usr/bin/env bash

set -eu
set -o pipefail

COMMAND_NAMES=( \
	ecr-upload \
	ecs-deploy \
	git-config-user \
	git-flow-release-finish \
	git-push-all \
	mvn-deploy \
	mvn-go-offline \
	mvn-license-format \
	mvn-release-perform \
	mvn-release-prepare \
	mvn-release \
	mvn-repackage \
	mvn-settings \
	mvn-test \
	popushd \
)

function self::install() {
	
	local location=${1}
	local name
	
	for name in ${COMMAND_NAMES[@]}; do
		
		curl -fsSL https://github.com/spt-oss/spt-ci-support/raw/feature/20170915-initial/command/${name}.sh -o ~${name}.sh
		
		chmod +x ~${name}.sh
		sudo mv ~${name}.sh ${1}/${name}
		
	done
}

{
	pushd /tmp/ > /dev/null
	
	self::install ${@}
	
	popd > /dev/null
}
