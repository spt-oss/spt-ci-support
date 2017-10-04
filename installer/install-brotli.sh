#!/usr/bin/env bash

set -eu
set -o pipefail

function self::install() {
	
	# Create cache
	if [ ! -d brotli ]; then
		
		git clone https://github.com/google/brotli.git
		
		pushd brotli/ > /dev/null
		
		self::make
		
		popd > /dev/null
	fi
	
	sudo cp -a brotli/bin/brotli /usr/local/bin/bro
}

function self::make() {
	
	# For CircleCI 2.0
	if [[ -v CIRCLECI ]] && [[ ! -x $(command -v make) ]]; then
		
		sudo apt-get -qq install make gcc
	fi
	
	make
}

{
	mkdir -p ${1}
	
	pushd ${1} > /dev/null
	
	self::install
	
	popd > /dev/null
	
	bro -h
}
