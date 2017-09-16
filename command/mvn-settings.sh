#!/usr/bin/env bash

set -eu
set -o pipefail

function self::command() {
	
	if [[ ${#} -gt 2 ]]; then
		
		local server=${1}
		local username=${2}
		local password=${3}
		
	else
		
		local server=${1}
		local username=
		local password=${2}
	fi
	
	local settings
	
	settings+='<?xml version="1.0" encoding="utf-8"?>'
	settings+='<settings>'
	settings+='<servers>'
	settings+='<server>'
	settings+='<id>'"${server}"'</id>'
	
	if [[ -n ${username} ]]; then
		
		settings+='<username>'"${username}"'</username>'
	fi
	
	settings+='<password>'"${password}"'</password>'
	settings+='</server>'
	settings+='</servers>'
	settings+='</settings>'
	
	mkdir -p ${HOME}/.m2
	
	echo ${settings} > ${HOME}/.m2/settings.xml
}

{
	self::command ${@}
}
