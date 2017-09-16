#!/usr/bin/env bash

set -eu
set -o pipefail

function self::command() {
	
	# TODO https://issues.apache.org/jira/browse/MDEP-516
	# TODO https://issues.apache.org/jira/browse/MDEP-568
	#mvn dependency:go-offline
	mvn install -DskipTests -Dcheckstyle.skip=true
	
	mvn help:help
	mvn clean:help
	mvn source:help
	mvn javadoc:help
	mvn resources:help
	mvn minify:help
	mvn compiler:help
	mvn surefire:help
	mvn jar:help
	mvn spring-boot:help
	mvn checkstyle:help
	mvn gpg:help
	mvn license:help
	mvn install:help
	mvn release:help
}

{
	self::command ${@}
}
