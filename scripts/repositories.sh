#!/bin/bash
#
#	Abhandlung Git Repositories
#

cd /vagrant
		
for	g in $*
do
	dir=`basename ${g##/} .git`
	
	# nur clonen wenn nicht vorhanden
	if	[ ! -d ${dir} ]
	then
		echo "git clone --depth=1 ${g}"
		git clone -q ${g}
	else
		echo "git pull ${g}"
		( cd ${dir} && git pull )
	fi

	
	# Repository spezifisches Script laufen lassen
	if	[ -f ${dir}/scripts/install.sh ]
	then
		echo "run ${dir}/scripts/install.sh"
		cd ${dir}
		bash scripts/install.sh
		cd ..
	fi
done
