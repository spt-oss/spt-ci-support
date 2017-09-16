#!/usr/bin/env bash

set -eu
set -o pipefail

function self::prepare() {
	
	# Check Java
	java -version > /dev/null
	
	# For CircleCI 1.0 (OLD)
	if [[ -d ${HOME}/.m2 ]] && [[ $(find ${HOME}/.m2 -maxdepth 1 -type d | grep -c apache-maven-) == 1 ]]; then
		
		pushd ${HOME}/.m2/apache-maven-* > /dev/null
		
		sudo ln -s ${PWD} /usr/local/apache-maven
		
		popd > /dev/null
		
	# For CircleCI 2.0 (Java)
	elif [[ $(find /opt -maxdepth 1 -type d | grep -c apache-maven-) == 1 ]]; then
		
		pushd /opt/apache-maven-* > /dev/null
		
		sudo ln -s ${PWD} /usr/local/apache-maven
		
		popd > /dev/null
	fi
}

function self::install() {
	
	local version=${1}
	local archive=apache-maven-${version}-bin.tar.gz
	
	if [ ! -f ${archive} ]; then
		
		curl -fsSLO https://archive.apache.org/dist/maven/maven-3/${version}/binaries/${archive}
	fi
	
	tar zxf ${archive}
	
	sudo rm -rf /usr/local/apache-maven/*
	sudo mv apache-maven-${version}/* /usr/local/apache-maven/
	
	rmdir apache-maven-${version}/
}

{
	[[ -v CIRCLECI ]] || exit ${?}
	
	self::prepare
	
	pushd /tmp/ > /dev/null
	
	self::install ${@}
	
	popd > /dev/null
	
	mvn --version
}
