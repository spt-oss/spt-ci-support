#!/usr/bin/env bash

set -eu
set -o pipefail

DELEGATE_URL=https://github.com/spt-oss/ecs-deploy/raw/feature/taskdefarn/ecs-deploy

docker_image=
aws_region=
ecs_service=
latest_task=false
task_family=
ecs_task=
arguments=()

function self::parse-arguments() {
	
	while [[ ${#} -gt 0 ]]
	do
		case ${1} in
			
			-i)
				docker_image=${2}
				shift
				;;
			
			-r)
				aws_region=${2}
				shift
				;;
			
			-n)
				ecs_service=${2}
				shift
				;;
			
			-ldn)
				latest_task=true
				;;
			
			-f)
				task_family=${2}
				shift
				;;
			
			*)
				arguments+=(${1})
				;;
		esac
		
		shift
	done
}

function self::determine-properties() {
	
	if [[ -z ${aws_region} ]]; then
		
		aws_region=$(echo ${docker_image} | grep -oP '\.ecr\.\K([^\.]+)') || :
	fi
	
	if [[ ${latest_task} != false ]] && [[ -n ${aws_region} ]]; then
		
		local prefix=${ecs_service}
		
		if [[ -n ${task_family} ]]; then
			
			prefix=${task_family}
		fi
		
		if [[ -n ${prefix} ]]; then
			
			ecs_task=$(aws ecs list-task-definitions \
				--region ${aws_region} --family-prefix ${prefix} --sort DESC --max-items 1 | \
				jq -r .taskDefinitionArns[]) || :
		fi
	fi
}

function self::validate-properties() {
	
	if [[ -z ${docker_image} ]]; then
		
		echo 'Usage: '$(basename ${0})' -i [docker-image] ......'
		
		exit 1
		
	elif [[ -z ${aws_region} ]]; then
		
		echo 'Usage: '$(basename ${0})' -r [aws-region] ......'
		
		exit 1
		
	elif [[ ${latest_task} != false ]] && [[ -z ${ecs_task} ]]; then
		
		echo 'Usage: '$(basename ${0})' -n [ecs-service] -ldn [prefix or empty] ......'
		
		exit 1
	fi
}

function self::rewrite-arguments() {
	
	arguments+=(-i)
	arguments+=(${docker_image})
	arguments+=(-r)
	arguments+=(${aws_region})
	
	if [[ -n ${ecs_service} ]]; then
		
		arguments+=(-n)
		arguments+=(${ecs_service})
	fi
	
	if [[ -n ${ecs_task} ]]; then
		
		arguments+=(-dn)
		arguments+=(${ecs_task})
	fi
}

function self::deploy() {
	
	local delegate=/tmp/ecs-deploy.delegate.sh
	
	if [ ! -f ${delegate} ]; then
		
		curl -fsSL ${DELEGATE_URL} -o ${delegate}
	fi
	
	chmod +x ${delegate}
	
	${delegate} ${arguments[@]}
}

{
	self::parse-arguments ${@}
	self::determine-properties
	self::validate-properties
	self::rewrite-arguments
	
	self::deploy
}
