#!/usr/bin/env bash

set -eu
set -o pipefail

EXECUTOR=${BASH_SOURCE%/*}/../../command/ecs-deploy.sh
DELEGATE=/tmp/ecs-deploy.delegate.sh

function test::before() {
	
	eval 'function ecs-deply() { source ${EXECUTOR} ${@}; }'
	eval 'function aws() { echo "{}"; }'
	
	mkdir -p $(dirname ${DELEGATE})
	echo 'echo ecs-deploy ${@}' > ${DELEGATE}
}

function test::enable-aws-error() {
	
	eval 'function aws() { echo "awscli error" >&2; return 1; }'
}

function test::enable-aws-task() {
	
	eval 'function aws() { echo "{ \"taskDefinitionArns\": [ \"arn:aws:ecs:xxxxx\" ] }"; }'
}

function test::disable-delegate-mock() {
	
	rm ${DELEGATE}
}

function test::after() {
	
	unset -f ecs-deply
	unset -f aws
	
	rm ${DELEGATE} || :
}

function test::assert-image-error() {
	
	(ecs-deply) && return 1
	
	echo $( (ecs-deply) ) | \
		grep 'Usage' | grep '\-i' || return ${?}
}

function test::assert-region-error() {
	
	(ecs-deply -i image) && return 1
	
	echo $( (ecs-deply -i image) ) | \
		grep 'Usage' | grep '\-r' || return ${?}
}

function test::assert-normal() {
	
	ecs-deply -i image -r us-west-1 | \
		grep '^ecs-deploy -i image -r us-west-1$' || return ${?}
	
	ecs-deply -i .ecr.us-west-1. | \
		grep '^ecs-deploy -i .ecr.us-west-1. -r us-west-1$' || return ${?}
	
	ecs-deply -i .ecr.us-west-1. -n service | \
		grep '^ecs-deploy -i .ecr.us-west-1. -r us-west-1 -n service$' || return ${?}
	
	ecs-deply -i .ecr.us-west-1. -n service -c cluster | \
		grep '^ecs-deploy -c cluster -i .ecr.us-west-1. -r us-west-1 -n service$' || return ${?}
}

function test::assert-latest-task() {
	
	(ecs-deply -i .ecr.us-west-1. -n service -ldn) && return 1
	
	echo $( (ecs-deply -i .ecr.us-west-1. -n service -ldn 2>&1 1>/dev/null) ) | \
		grep 'Cannot iterate' || return ${?}
	echo $( (ecs-deply -i .ecr.us-west-1. -n service -ldn 2>/dev/null) ) | \
		grep 'Usage' | grep '\-ldn' || return ${?}
	
	test::enable-aws-error
	
	(ecs-deply -i .ecr.us-west-1. -n service -ldn) && return 1
	
	echo $( (ecs-deply -i .ecr.us-west-1. -n service -ldn 2>&1 1>/dev/null) ) | \
		grep 'awscli error' || return ${?}
	
	test::enable-aws-task
	
	ecs-deply -i .ecr.us-west-1. -n service -ldn | \
		grep '^ecs-deploy .* -n service -dn arn:aws:ecs:xxxxx$' || return ${?}
}

function test::assert-delegate() {
	
	test::disable-delegate-mock
	
	ecs-deply -i .ecr.us-west-1. -n example -ldn && return 1
	
	echo $(ecs-deply -i .ecr.us-west-1. -n example -ldn) | \
		grep '\--cluster' || return ${?}
}

function test::run() {
	
	local status=0
	
	test::before
	
	test::assert-image-error && \
		test::assert-region-error && \
		test::assert-normal && \
		test::assert-latest-task && \
		test::assert-delegate || status=${?}
	
	test::after
	
	exit ${status}
}

{
	test::run
}
