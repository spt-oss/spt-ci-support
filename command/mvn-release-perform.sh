#!/usr/bin/env bash

set -eu
set -o pipefail

function self::command() {
	
	mvn release:perform --batch-mode -Darguments="-DskipTests" ${@}
}

{
	self::command ${@}
}
