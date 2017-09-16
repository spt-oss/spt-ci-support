#!/usr/bin/env bash

set -eu
set -o pipefail

function self::install() {
	
	local location=${1}
	
	curl -fsSLO https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic-java.zip
	unzip -q newrelic-java.zip
	
	mv newrelic/newrelic.jar ${location}
	
	rm -r newrelic/
	rm newrelic-java.zip
}

{
	pushd /tmp/ > /dev/null
	
	self::install ${@}
	
	popd > /dev/null
}
