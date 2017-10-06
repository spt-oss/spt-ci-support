#!/usr/bin/env bash

set -eu
set -o pipefail

repo_uri=
aws_region=
repo_name=
filter_date=
max_items=

function self::parse-arguments() {
	
	while [[ ${#} -gt 0 ]]; do
		
		case ${1} in
			
			--repository-uri)
				repo_uri=${2:-}
				shift
				;;
			
			--filter-date)
				filter_date=${2:-}
				shift
				;;
			
			--max-items)
				max_items=${2:-}
				shift
				;;
		esac
		
		shift
	done
}

function self::determine-properties() {
	
	aws_region=$(echo ${repo_uri} | grep -oP '\.ecr\.\K([^\.]+)' || :)
	repo_name=$(echo ${repo_uri} | grep -oP 'aws\.com/\K([^:]+)' || :)
	
	if [[ -n ${filter_date} ]]; then
		
		filter_date=$(date +%s --date "${filter_date}" || :)
	fi
}

function self::validate-properties() {
	
	if [[ -z ${aws_region} ]] || [[ -z ${repo_name} ]]; then
		
		echo 'Usage: '$(basename ${0}) \
			'--repository-uri <ecr-repository-uri> ......'
		
		exit 1
		
	elif [[ -z ${filter_date} ]]; then
		
		echo 'Usage: '$(basename ${0}) \
			'--filter-date <date-command-d-format> ......'
		
		exit 1
		
	elif [[ ! ${max_items} =~ ^[0-9]+$ ]]; then
		
		echo 'Usage: '$(basename ${0}) \
			'--max-items <max-delete-items> ......'
		
		exit 1
	fi
}

function self::clean() {
	
	local image_details=$(aws ecr describe-images \
		--region ${aws_region} \
		--repository-name ${repo_name})
	
	echo ${image_details}
	
	local image_digests=( $(echo "${image_details}" | \
		jq -r '.imageDetails[] | ' \
			'select(.imagePushedAt < '${filter_date}') | ' \
			'sort_by(.imagePushedAt) | ' \
			'.[:'${max_items}'] | ' \
			'.[].imageDigest' || :) )
	
	echo ${image_digests}
	
	local image_digest
	
	for image_digest in ${image_digests[@]:-}; do
		
		aws ecr batch-delete-image \
			--region ${aws_region} \
			--repository-name ${repo_name} \
			--image-ids imageDigest=${image_digest}
	done
}

{
	self::parse-arguments ${@}
	self::determine-properties
	self::validate-properties
	
	self::clean
}
