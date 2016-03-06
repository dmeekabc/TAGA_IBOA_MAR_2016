####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

# get the inputs
outputDir=$1
iter=$2
startTime=$3
startDTG=$4

# archive directory processing
if [ $TESTONLY -eq 1 ] ; then
  # use the testing directory for testing
  outputDir=$OUTPUT_DIR/output
fi 
# go to the output Directory for processing
cd $outputDir

# get Gross Received Count
let grossReceivedCount=0

# Get Multicast Received Counts
if [ $TESTTYPE == "MCAST" ]; then
  for target in $targetList
  do
    HOST=`cat $TAGA_DIR/hostsToIps.txt | grep $target\\\. | cut -d"." -f 5`
    SOURCE_FILE_TAG=$TEST_DESCRIPTION\_$HOST\_*$target\_
    # get our target receive count
    let targetReceivedCount=`cat $SOURCE_FILE_TAG* | grep -v $target | wc -l`
    let grossReceivedCount=$grossReceivedCount+$targetReceivedCount
  done
else
  # Get Unicast Received Counts
  for target in $targetList
  do
    HOST=`cat $TAGA_DIR/hostsToIps.txt | grep $target\\\. | cut -d"." -f 5`
    SOURCE_FILE_TAG=$TEST_DESCRIPTION\_$HOST\_*$target\_
    # get receivers only and only our target
    let targetReceivedCount=`cat $SOURCE_FILE_TAG* | cut -d">" -f 2- | grep $target | wc -l`
    let grossReceivedCount=$grossReceivedCount+$targetReceivedCount
  done
fi


#####################################################
# Build the Top Line of the File
#####################################################
#####################################################

# calculate the expected line count
let expectedCount=$MSGCOUNT
let expectedCount2=0

#let expectedCount3=0

for target in $targetList
do
   # count the nodes we send our message to
   # check the test type

      # if UCAST, we send a message to each node, except ourself
      for target2 in $targetList
      do
        if [ $target2 != $MYIP ]; then
           let expectedCount2=$expectedCount2+1
        fi
      done

done

let expectedCount=$expectedCount*$expectedCount2

let numerator=$grossReceivedCount
let printCount=$numerator

let numerator=$numerator*10000
let denominator=$expectedCount
let percent=$numerator/$denominator 

let checkValue=$numerator/10000 
if [ $checkValue -eq $denominator ]; then
  percent="100.00"
else
  percent=`echo $percent | cut -c1-2`.`echo $percent | cut -c3-4`
  if [ $percent == "0." ]; then
     percent="0.0"
  fi
fi


# write to output
echo
echo Iteration:$iter : Total Files:`ls $outputDir | wc -l` Rec\'d Count:$printCount / $expectedCount exp msgs \($percent%\)

# write to counts.txt file
echo >> $TAGA_DIR/counts.txt
echo Iteration:$iter : Total Files:`ls $outputDir | wc -l` Rec\'d Count:$printCount / $expectedCount exp msgs \($percent%\) >> $TAGA_DIR/counts.txt


#####################################################
# Build the Second Line of the File
#####################################################
#####################################################
# calculate the expected line count
let expectedCount=$MSGCOUNT
let expectedCount2=0
let expectedCount3=0
for target in $targetList
do
   # count the nodes we send our message to
   # check the test type

   # if UCAST, we send a message to each node, except ourself
   # but this expected message count is even valid for the MCAST 
   # since we count on the receive side
   for target2 in $targetList
   do
      if [ $target2 != $MYIP ]; then
         let expectedCount2=$expectedCount2+1
      fi
   done

   # accumulate the mcast sends counts
   if [ $TESTTYPE == "MCAST" ]; then
      # if MCAST, we send only one message per all nodes
      let expectedCount3=$expectedCount3+1
   fi

done

if [ $TESTTYPE == "MCAST" ]; then
   let expectedCount=$expectedCount*1
else
   let expectedCount=$expectedCount*2
fi

if [ $TESTTYPE == "MCAST" ]; then
   let expectedCount=$expectedCount*$expectedCount2
   let expectedCount3=$expectedCount3*$MSGCOUNT
   let expectedCount=$expectedCount+$expectedCount3
else
   let expectedCount=$expectedCount*$expectedCount2
fi

let numerator=`cat $outputDir/* | wc -l`
let numerator=$numerator*10000
let denominator=$expectedCount
let percent=$numerator/$denominator 

let checkValue=$numerator/10000 
if [ $checkValue -eq $denominator ]; then
  percent="100.00"
else
  percent=`echo $percent | cut -c1-2`.`echo $percent | cut -c3-4`
  if [ $percent == "0." ]; then
     percent="0.0"
  fi
fi

# write to output
echo Iteration:$iter : Total Files:`ls $outputDir | wc -l` Total Count:`cat $outputDir/* | wc -l` / $expectedCount exp msgs \($percent%\)

# write to counts.txt file
echo Iteration:$iter : Total Files:`ls $outputDir | wc -l` Total Count:`cat $outputDir/* | wc -l` / $expectedCount exp msgs \($percent%\) >> $TAGA_DIR/counts.txt


##################################################################
# PRINT HEADER ROWS
##################################################################
$TAGA_DIR/printSendersHeader.sh "SENDERS" $iter $startTime $startDTG

###################
# MAIN COUNT/SORT
###################

curcount="xxxx"

for target in $targetList
do

  # build Row output

  # pad target name as necessary to have nice output
  tgtlen=`echo $target | awk '{print length($0)}'`

  if [ $tgtlen -eq 17 ] ; then
    row=$target\ 
  elif [ $tgtlen -eq 16 ] ; then
    row=$target\. 
  elif [ $tgtlen -eq 15 ] ; then
    row=$target\.. 
  elif [ $tgtlen -eq 14 ] ; then
    row=$target\... 
  elif [ $tgtlen -eq 13 ] ; then
    row=$target\.... 
  elif [ $tgtlen -eq 12 ] ; then
    row=$target\..... 
  elif [ $tgtlen -eq 11 ] ; then
    row=$target\..... 
  elif [ $tgtlen -eq 10 ] ; then
    row=$target\...... 
  else
    row=$target\....... 
  fi

  # get the sent count for (to) this target
  for target2 in $targetList
  do
    if [ $target == $target2 ] ; then
      # skip self
      curcount="xxxx"
    else

      # else get the count for this target
      HOST=`cat $TAGA_DIR/hostsToIps.txt | grep $target\\\. | cut -d"." -f 5`
      SOURCE_FILE_TAG=$TEST_DESCRIPTION\_$HOST\_*$target\_

      # make sure we are starting with empty files
      rm /tmp/curcount.txt /tmp/curcount2.txt 2>/dev/null
      touch /tmp/curcount.txt /tmp/curcount2.txt
      
      # write to the curcount.txt file
      cat $SOURCE_FILE_TAG* | grep $target\\\. > /tmp/curcount.txt 2>/dev/null

      # mcast or ucast? 
      if [ $TESTTYPE == "MCAST" ]; then
        # MCAST
        target2=$MYMCAST_ADDR
        cat /tmp/curcount.txt  | grep $target2\. | grep $target.$SOURCEPORT > /tmp/curcount2.txt # filter
        cat /tmp/curcount2.txt  | grep "length $MSGLEN" > /tmp/curcount.txt  # verify length
        cat /tmp/curcount.txt  > /tmp/curcount2.txt   # copy the output to temp file curcount2.txt
        cat /tmp/curcount2.txt | wc -l                > /tmp/curcount.txt   # get the count
      elif [ $TESTTYPE == "UCAST_TCP" ]; then
        # UCAST_TCP
        # Note, this UCAST_TCP case is currently the same as the UCAST_UDP case below
        # Note, if this UCAST_TCP case requires special update in the future, similar
        # changes may require a similar block update in the countReceives.sh file
        cat /tmp/curcount.txt  | cut -d">" -f 2-      > /tmp/curcount2.txt  # get receivers only
        cat /tmp/curcount2.txt | grep $target2\\\.      > /tmp/curcount.txt   # remove all except target2 rows
        cat /tmp/curcount.txt  | grep "length $MSGLEN" > /tmp/curcount2.txt  # verify length
        cat /tmp/curcount2.txt | wc -l                > /tmp/curcount.txt   # get the count
      else
        # UCAST_UDP
        cat /tmp/curcount.txt  | cut -d">" -f 2-      > /tmp/curcount2.txt  # get receivers only
        cat /tmp/curcount2.txt | grep $target2\\\.      > /tmp/curcount.txt   # remove all except target2 rows
        cat /tmp/curcount.txt  | grep "length $MSGLEN" > /tmp/curcount2.txt  # verify length
        cat /tmp/curcount2.txt | wc -l                > /tmp/curcount.txt   # get the count
      fi

      # populate curcount from the curcount.txt file
      let curcount=`cat /tmp/curcount.txt`

      # pad as necessary
      let mycount=$curcount
      if [ $mycount -lt 10 ] ; then
        # pad
        echo 000$curcount > /dev/null
        curcount=000$curcount
      elif [ $mycount -lt 100 ] ; then
        # pad
        echo 00$curcount > /dev/null
        curcount=00$curcount
      elif [ $mycount -lt 1000 ] ; then
        # pad
        echo 0$curcount > /dev/null
        curcount=0$curcount
      else
        # no pad needed
        echo $node > /dev/null
      fi

      if [ -f  $SOURCE_FILE_TAG*$target_ ] ; then
        echo file exists! >/dev/null
      else
        echo file NO exists! >/dev/null
        curcount="----"
      fi 2>/dev/null
    fi 
    
    # append count to the row string
    row="$row  $curcount"

  done # continue to next target

  echo $row
  echo $row >> $TAGA_DIR/counts.txt
  echo $row >> $TAGA_DIR/countsSends.txt

done

