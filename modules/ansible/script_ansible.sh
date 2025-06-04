#!/bin/bash

echo "Fasi preliminari .... "

echo -e "\n"

echo "Creazione utente ansible e aggiunta utente gruppo sudo"

useradd -m ansible -s /bin/bash

usermod -aG sudo ansible

echo "permettere all'utente che si trova nel gruppo sudo di fare cose senza password..."

sed -E -i 's/%(sudo)\s(ALL=\(ALL\:ALL\)\s(ALL))/%sudo  ALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers

cd /home/ansible && mkdir .ssh/ && ssh-keygen -b 4098 -t rsa -f /home/ansible/.ssh/id_rsa -P ""

for i in {0...10}; do
	if curl -s www.google.com > /dev/null; then

		apt update && apt install -y ansible
		echo "Installazione ansible completata!!! "

        break;
	else
		echo "Installazione Ansible non riuscita!!!! "
		sleep 10
	fi
    echo "$i" >> log.txt
done