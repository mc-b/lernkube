#!/bin/bash
#
# 	Aufraeumen
#

sudo rm -f /home/vagrant/docker*.deb

mkdir -p /vagrant/cr-cache

for i in $(docker images | cut -d ' ' -f 1 | grep -v REPOSITORY)
do
    OUT="/vagrant/cr-cache/$(echo ${i} | tr / _).tar"
    [ ! -f ${OUT} ] && { echo "save image ${i} to ${OUT}"; docker save ${i} -o ${OUT}; }
done

# umount /vagrant

exit 0
