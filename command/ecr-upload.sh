#!/usr/bin/env bash

set -eu
set -o pipefail

docker_tag=
aws_region=
login_args=()
build_args=()

function self::parse-arguments() {
	
	while [[ ${#} -gt 0 ]]
	do
		case ${1} in
			
			-t)
				docker_tag=${2}
				shift
				;;
			
			--no-include-email)
				login_args+=(${1})
				;;
			
			*)
				build_args+=(${1})
				;;
		esac
		
		shift
	done
}

function self::determine-properties() {
	
	aws_region=$(echo ${docker_tag} | grep -oP '\.ecr\.\K([^\.]+)') || :
}

function self::validate-properties() {
	
	if [[ -z ${aws_region} ]]; then
		
		echo 'Usage: '$(basename ${0})' -t [ecr-repository-uri]:[tag] ......'
		
		exit 1
	fi
}

function self::rewrite-arguments() {
	
	login_args=(--region ${aws_region} ${login_args[@]-})
	build_args=(-t ${docker_tag} ${build_args[@]-})
}

function self::upload() {
	
	$(aws ecr get-login ${login_args[@]-})
	
	docker build ${build_args[@]-}
	docker push ${docker_tag}
}

{
	self::parse-arguments ${@}
	self::determine-properties
	self::validate-properties
	self::rewrite-arguments
	
	self::upload
}
