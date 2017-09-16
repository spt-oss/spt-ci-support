#!/usr/bin/env bash

set -eu
set -o pipefail

EXECUTOR=${BASH_SOURCE%/*}/../../command/ecr-upload.sh

function test::before() {
	
	eval 'function ecr-upload() { source ${EXECUTOR} ${@}; }'
	eval 'function aws() { eval echo aws ${@}; }'
	eval 'function docker() { eval echo docker ${@}; }'
}

function test::after() {
	
	unset -f ecr-upload
	unset -f aws
	unset -f docker
}

function test::assert-image-error() {
	
	(ecr-upload) && return ${?}
	
	echo $( (ecr-upload) ) | \
		grep 'Usage' || return ${?}
}

function test::assert-region-error() {
	
	(ecr-upload -t image) && return ${?}
	
	echo $( (ecr-upload -t image) ) | \
		grep 'Usage' || return ${?}
}

function test::assert-normal() {
	
	ecr-upload -t .ecr.us-west-1. --build-arg a=b | \
		grep '^aws ecr get-login --region us-west-1$' || return ${?}
	
	ecr-upload -t .ecr.us-west-1. --no-include-email | \
		grep '^aws ecr get-login --region us-west-1 --no-include-email$' || return ${?}
	
	ecr-upload -t .ecr.us-west-1. --build-arg a=b | \
		grep '^docker build -t .ecr.us-west-1. --build-arg a=b$' || return ${?}
	
	ecr-upload -t .ecr.us-west-1. --build-arg a=b | \
		grep '^docker push .ecr.us-west-1.$' || return ${?}
}

function test::run() {
	
	local status=0
	
	test::before
	
	test::assert-image-error && \
		test::assert-region-error && \
		test::assert-normal || status=${?}
	
	test::after
	
	exit ${status}
}

{
	test::run
}
