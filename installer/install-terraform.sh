#!/usr/bin/env bash

set -eu
set -o pipefail

function self::install() {
	
	local version=${1}
	local archive=terraform_${version}_linux_amd64.zip
	
	if [ ! -f ${archive} ]; then
		
		curl -fsSLO https://releases.hashicorp.com/terraform/${version}/${archive}
	fi
	
	unzip -q ${archive}
	
	sudo mv terraform /usr/local/bin/
}

{
	mkdir -p ${1}
	
	pushd ${1} > /dev/null
	
	self::install ${@:2}
	
	popd > /dev/null
	
	terraform --version
}
