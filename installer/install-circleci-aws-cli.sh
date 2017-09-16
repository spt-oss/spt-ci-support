#!/usr/bin/env bash

set -eu
set -o pipefail

function self::prepare() {
	
	# Check Python
	python --version > /dev/null
	
	# For CircleCI 2.0 (Node)
	if [[ $(dpkg -l | grep -c python-dev) == 0 ]]; then
		
		sudo apt-get -qq install python-dev
	fi
	
	# For CircleCI 2.0
	if [[ ! -x $(command -v pip) ]]; then
		
		curl -fsSL https://bootstrap.pypa.io/get-pip.py | sudo python
	fi
}

function self::install() {
	
	# For CircleCI 1.0 || For CircleCI 2.0 & 1.0 (OLD)
	pip install --upgrade awscli 2>/dev/null || sudo pip install --upgrade awscli
}

{
	[[ -v CIRCLECI ]] || exit ${?}
	
	self::prepare
	self::install ${@}
	
	aws --version
}
