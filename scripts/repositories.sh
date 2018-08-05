#!/bin/bash
#
#	Abhandlung Git Repositories
#
cd /vagrant/`hostname`
	
for	g in $*
do
	git clone ${g}
	dir=`basename ${g##/} .git`
	
	# Repository spezifisches Script laufen lassen
	if	[ -f ${dir}/scripts/install.sh ]
	then
		cd ${dir}
		bash scripts/install.sh
		cd ..
	fi
done