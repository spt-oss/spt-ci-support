#!/usr/bin/env bash

set -eu
set -o pipefail

function self::prepare() {
	
	# Remove previous keys if found
	rm -f ${HOME}/.gnupg/*.gpg*
	
	# Create directory if not found
	mkdir -p ${HOME}/.gnupg
	chmod 700 ${HOME}/.gnupg/
}

function self::install() {
	
	local pub_url=$(curl -fsSL -w %{url_effective} -o /dev/null ${1})
	local password=${2}
	
	curl -fsSL ${pub_url}                 -o pubring.gpg.enc
	curl -fsSL ${pub_url/pubring/secring} -o secring.gpg.enc
	
	openssl aes-256-cbc -d -in pubring.gpg.enc -out ${HOME}/.gnupg/pubring.gpg -k ${password}
	openssl aes-256-cbc -d -in secring.gpg.enc -out ${HOME}/.gnupg/secring.gpg -k ${password}
	
	rm pubring.gpg.enc
	rm secring.gpg.enc
}

{
	self::prepare
	
	pushd /tmp/ > /dev/null
	
	self::install ${@}
	
	popd > /dev/null
	
	gpg --list-keys        | grep pub
	gpg --list-secret-keys | grep sec
}
