#!/usr/bin/env bash

set -eu
set -o pipefail

function self::command() {
	
	# TODO https://issues.apache.org/jira/browse/MDEP-516
	# TODO https://issues.apache.org/jira/browse/MDEP-568
	#mvn dependency:go-offline
	
	# Install plugins, dependencies and artifacts
	mvn install --batch-mode -DskipTests -Dcheckstyle.skip=true
	
	# Install plugins after install
	mvn \
		javadoc:help \
		spring-boot:help \
		--batch-mode
}

{
	self::command ${@}
}
