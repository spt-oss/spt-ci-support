#!/usr/bin/env bash

set -eu
set -o pipefail

function self::install() {
	
	curl -fsSLO https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic-java.zip
	unzip -q newrelic-java.zip
	
	mv newrelic/newrelic.jar .
	
	rm -r newrelic/
	rm newrelic-java.zip
}

{
	mkdir -p ${1}
	
	pushd ${1} > /dev/null
	
	self::install
	
	popd > /dev/null
}
