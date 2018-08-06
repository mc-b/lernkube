#!/bin/bash
#
# 	Feintuning Default Router
#
#	Damit mehrere Nodes mit einnander kommunzieren koennen braucht es eine public IP pro Node und ein Default GW


if	[ "$1" != "" ]
then
	echo $*
	$*
fi

