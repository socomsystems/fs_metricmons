#!/bin/bash

MASTER_IP='X.X.X.191/32'
NODE_NAME='node.domain.name'
AVG_REGS=200

REGS_COUNT=$(/usr/bin/fs_cli -x "show registrations count" | awk '/total/ {print $1}')
AMI_MASTER=$(/sbin/ip addr | awk '/scope global dummy0/ {print $2}')
echo $REGS_COUNT
echo $AVG_REGS
echo $MASTER_IP
echo $AMI_MASTER

if [ $REGS_COUNT -lt $AVG_REGS ] && [ $AMI_MASTER=$MASTER_IP ]; then
        FROM="ALERT@$NODE_NAME"
        SUBJECT="Endpoint Registrations Low"
        TOEMAIL="admin@domain.name"
        /usr/bin/mailx "-aFrom:$FROM" -s "$SUBJECT" "$TOEMAIL"<<END
Registrations count is $REGS_COUNT which is below average of $AVG_REGS on master node $NODE_NAME.
END

/usr/bin/logger -p local0.info -t rc-status -i I am master node and registrations count is $REGS_COUNT, marking critical

elif [ -z $AMI_MASTER ]; then

/usr/bin/logger -p local0.info -t rc-status -i I am not master node and registrations count is $REGS_COUNT, marking acceptable 

elif [ $REGS_COUNT -ge $AVG_REGS ] && [ $AMI_MASTER=$MASTER_IP ]; then

/usr/bin/logger -p local0.info -t rc-status -i I am master node and registrations count is $REGS_COUNT, marking acceptable

fi
