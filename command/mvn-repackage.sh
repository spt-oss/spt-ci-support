#!/usr/bin/env bash

set -eu
set -o pipefail

function self::command() {
	
	mvn clean package spring-boot:repackage -DskipTests
}

{
	self::command ${@}
}
