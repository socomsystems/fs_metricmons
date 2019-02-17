#!/bin/bash

# Capture number of channels in use and send to syslog
MAX_CALLS=1000
CHANNEL_COUNT=$(/usr/bin/fs_cli -x "show channels count" | awk '/total/ {print $1}')
/usr/bin/logger -p local0.info -t cc-status -i has reached $CHANNEL_COUNT calls.

# Divide channels by 2 to reflect accurate call count
if [ "$CHANNEL_COUNT" = "0" ]; then 
   fscallcount=0; 
else fscallcount=`echo $CHANNEL_COUNT/2 | bc`;
fi

# Send call count to NetData via statsd!
echo "callcount:$fscallcount:|g" | nc -w 1 -u localhost 8125

if [ $CHANNEL_COUNT -gt $MAX_CALLS ]; then
        FROM="ALERT@domain.name"
        SUBJECT="High Call Volume"
        TOEMAIL="admin@domain.name"
        /usr/bin/mailx "-aFrom:$FROM" -s "$SUBJECT" "$TOEMAIL"<<END
Alert, node call count is $CHANNEL_COUNT.  Max calls threshold is $MAX_CALLS.
END

/usr/bin/logger -p local0.crit -t cc-status -i has reached $CHANNEL_COUNT calls, marking critical
fi
/usr/bin/logger -p local0.info -t cc-status -i has reached $CHANNEL_COUNT calls, marking acceptable
