#!/bin/bash
#
# 	Aufraeumen
#

# nur wenn docker installiert
which docker
if [ $? -eq 0 ]
then

    sudo rm -f /home/vagrant/docker*.deb

    mkdir -p /vagrant/cr-cache

    docker image prune -f
    for i in $(docker images | cut -d ' ' -f 1 | grep -v REPOSITORY)
    do
        OUT="/vagrant/cr-cache/$(echo ${i} | tr / _).tar"
        [ ! -f ${OUT} ] && { echo "save image ${i} to ${OUT}"; docker save ${i} -o ${OUT}; }
    done
fi

# umount /vagrant

exit 0
