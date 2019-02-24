#! /bin/bash

#write ulimit value to supervisor
ehco "
ulimit -n 51200" >> /etc/default/supervisor

#fix ssmgr-tiny restart rule in crontab
sed -i '$s#supervisorctl reload#sueprvisorctl stop ssmgr-tiny && supervisorctl start ssmgt-tiny#g' /etc/crontab
