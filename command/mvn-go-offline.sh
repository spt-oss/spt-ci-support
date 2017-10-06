#!/usr/bin/env bash

set -eu
set -o pipefail

function self::command() {
	
	# TODO https://issues.apache.org/jira/browse/MDEP-516
	# TODO https://issues.apache.org/jira/browse/MDEP-568
	#mvn dependency:go-offline
	mvn install -DskipTests -Dcheckstyle.skip=true
	
	mvn \
		help:help \
		clean:help \
		source:help \
		javadoc:help \
		resources:help \
		minify:help \
		compiler:help \
		surefire:help \
		jar:help \
		spring-boot:help \
		checkstyle:help \
		gpg:help \
		license:help \
		install:help \
		release:help
}

{
	self::command ${@}
}
