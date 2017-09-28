#!/usr/bin/env bash

set -eu
set -o pipefail

COMMAND_AWS=( \
	ecr-upload \
	ecs-deploy \
)

COMMAND_GIT=( \
	git-config-user \
	git-flow-release-finish \
	git-push-all \
)

COMMAND_MVN=( \
	mvn-deploy \
	mvn-go-offline \
	mvn-license-format \
	mvn-release-perform \
	mvn-release-prepare \
	mvn-release \
	mvn-repackage \
	mvn-settings \
	mvn-test \
)

function self::install() {
	
	local location=${1}
	local group=${2:-aws,git,mvn}
	local name
	
	if [[ ${group} =~ aws ]]; then
		
		for name in ${COMMAND_AWS[@]}; do
			
			self::import ${location} ${name}
		done
	fi
	
	if [[ ${group} =~ git ]]; then
		
		for name in ${COMMAND_GIT[@]}; do
			
			self::import ${location} ${name}
		done
	fi
	
	if [[ ${group} =~ mvn ]]; then
		
		for name in ${COMMAND_MVN[@]}; do
			
			self::import ${location} ${name}
		done
	fi
}

function self::import() {
	
	local location=${1}
	local name=${2}
	
	curl -fsSL https://github.com/spt-oss/spt-ci-support/raw/master/command/${name}.sh -o ~${name}.sh
	
	chmod +x ~${name}.sh
	sudo mv ~${name}.sh ${location}/${name}
}

{
	pushd /tmp/ > /dev/null
	
	self::install ${@}
	
	popd > /dev/null
}
