#!/usr/bin/env bash

set -eu
set -o pipefail

function self::command() {
	
	mvn license:format
}

{
	self::command ${@}
}
