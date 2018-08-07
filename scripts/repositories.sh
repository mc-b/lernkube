#!/bin/bash
#
#	Abhandlung Git Repositories
#
cd /vagrant/`hostname`
	
for	g in $*
do
	echo "git clone --depth=1 ${g}"
	git clone -q ${g}
	dir=`basename ${g##/} .git`
	
	# Repository spezifisches Script laufen lassen
	if	[ -f ${dir}/scripts/install.sh ]
	then
		echo "run ${dir}/scripts/install.sh"
		cd ${dir}
		bash scripts/install.sh
		cd ..
	fi
done