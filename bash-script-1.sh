#! /bin/bash

#write ulimit value to supervisor
echo "
ulimit -n 51200" >> /etc/default/supervisor

#fix ssmgr-tiny restart rule in crontab
sed -i '$s#supervisorctl reload#sueprvisorctl stop ssmgr-tiny && supervisorctl start ssmgt-tiny#g' /etc/crontab

#setting server reboot time
echo "
5 5 25 2 1  reboot" >> /etc/crontab &&
service cron reload
