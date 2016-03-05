#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

# order matters! stop generators (mgen) before monitors (tcpdump)
KILL_LIST="mgen survey xxx tcpdump" 

for proc_name in $KILL_LIST
do
   # Kill the process id(s) of the proc name
   KILL_LIST2=`ps -ef | grep \$proc_name | grep -v grep | cut -c10-15` 
   echo killing $proc_name ....  Kill_list: $KILL_LIST2
   sudo kill -9 $KILL_LIST2 <$TAGA_DIR/passwd.txt < $TAGA_DIR/passwd.txt
done

