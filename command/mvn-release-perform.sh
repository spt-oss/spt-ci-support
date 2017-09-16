#!/usr/bin/env bash

set -eu
set -o pipefail

function self::command() {
	
	mvn release:perform --batch-mode ${@}
}

{
	self::command ${@}
}
