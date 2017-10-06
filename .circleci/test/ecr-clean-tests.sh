#!/usr/bin/env bash

set -eu
set -o pipefail

EXECUTOR=${BASH_SOURCE%/*}/../../command/ecr-clean.sh

function test::before() {
	
	eval 'function ecr-clean() { source ${EXECUTOR} ${@}; }'
	eval 'function aws() { echo aws ${@} >&2; exit 1; }'
}

function test::enable-aws-task() {
	
	eval 'function aws() { echo "{ \"taskDefinitionArns\": [ \"arn:aws:ecs:xxxxx\" ] }"; }'
}

function test::after() {
	
	unset -f ecr-clean
	unset -f aws
}

function test::assert-properties() {
	
	local repo_uri=.ecr.us-west-1.amazonaws.com/foo
	local filter_date='7 day ago'
	
	# --repository-uri
	(ecr-clean) && return ${?}
	
	echo $( (ecr-clean) ) | \
		grep -P 'Usage: (?:.*?) --repository-uri' || return ${?}
	
	# --filter-date
	(ecr-clean --repository-uri ${repo_uri}) && return ${?}
	
	echo $( (ecr-clean --repository-uri ${repo_uri}) ) | \
		grep -P 'Usage: (?:.*?) --filter-date' || return ${?}
	
	(ecr-clean --repository-uri ${repo_uri} --filter-date foo) && return ${?}
	
	echo $( (ecr-clean --repository-uri ${repo_uri} --filter-date foo) ) | \
		grep -P 'Usage: (?:.*?) --filter-date' || return ${?}
	
	# --max-items
	(ecr-clean --repository-uri .${repo_uri} \
		--filter-date ${filter_date}) && return ${?}
	
	echo $( (ecr-clean --repository-uri ${repo_uri} \
		--filter-date ${filter_date}) ) | \
		grep -P 'Usage: (?:.*?) --max-items' || return ${?}
	
	(ecr-clean --repository-uri ${repo_uri} \
		--filter-date ${filter_date} --max-items foo) && return ${?}
	
	echo $( (ecr-clean --repository-uri ${repo_uri} \
		--filter-date ${filter_date} --max-items foo) ) | \
		grep -P 'Usage: (?:.*?) --max-items' || return ${?}
}

function test::assert-clean() {
	
	: # TODO
}

function test::run() {
	
	local status=0
	
	test::before
	
	test::assert-properties && \
		test::assert-clean || status=${?}
	
	test::after
	
	exit ${status}
}

{
	test::run
}
