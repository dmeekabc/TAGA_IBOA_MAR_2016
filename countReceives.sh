#####################################################
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

##################################################################
# PRINT HEADER ROWS
##################################################################
$TAGA_DIR/printReceiversHeader.sh RECEIVERS $iter $startTime $startDTG

###################
# MAIN COUNT/SORT
###################

curcount="xxxx"

# init the columns cumulative
let column_cumulative_count=0
let column_target_cumulative_count=0
let i=0
let j=0
for target in $targetList
do
     # create dynamic vars to hold the column counts and init to 0
     let j=$j+1
     p_val=$j
     active_id=$p_val
     declare "flag_$active_id"=0
done

for target in $targetList
do

  # reset the per target cumulative
  #let column_target_cumulative_count=0

  # build Row output

  # init the row cumulative
  let row_cumulative=0

  # create the column containers
  let i=$i+1
  #let i.pt=$i

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

  let j=0

  # get the received count for (to) this target
  for target2 in $targetList

  do

     # create the inner loop column containers
     let j=$j+1
     #p_val=$j
     #active_id=$p_val
     #declare "flag_$active_id"=0
     #let i.pt=$i

    if [ $target == $target2 ] ; then
      # skip self
      curcount="xxxx"
    else

      # else get the count for this target

      HOST=`cat $TAGA_DIR/hostsToIps.txt | grep $target2\\\. | cut -d"." -f 5`
      DEST_FILE_TAG=$TEST_DESCRIPTION\_$HOST\_*$target2\_

      # write to the curcount.txt file
      cat $DEST_FILE_TAG* > /tmp/curcount.txt 2>/dev/null

      # mcast or ucast? 
      if [ $TESTTYPE == "MCAST" ]; then
        # MCAST
        cat /tmp/curcount.txt  | grep "length $MSGLEN" > /tmp/curcount2.txt # verify length
        cat /tmp/curcount2.txt | cut -d">" -f 1       > /tmp/curcount.txt  # get senders only
        cat /tmp/curcount.txt  | grep $target\.      > /tmp/curcount2.txt # filter on the target (row)
        cat /tmp/curcount2.txt | wc -l                > /tmp/curcount.txt  # get the count
      else
        # UCAST
        cat /tmp/curcount.txt  | grep "length $MSGLEN" > /tmp/curcount2.txt # verify length
        cat /tmp/curcount2.txt | cut -d">" -f 1       > /tmp/curcount.txt  # get senders only
        cat /tmp/curcount.txt  | grep $target\\\.      > /tmp/curcount2.txt # filter on the target (row)
        cat /tmp/curcount2.txt | wc -l                > /tmp/curcount.txt  # get the count
      fi

      # populate curcount from the curcount.txt file
      let curcount=`cat /tmp/curcount.txt`

      # add this count to the cumulative
      let row_cumulative=$row_cumulative+$curcount
      #column_cumulative=$column_cumulative+$curcount

      #echo 11111111111 : i:$i j:$j : $target  : $curcount
      let column_cumulative_count=$column_cumulative_count+$curcount

      #if [ $i -eq $j ]; then
        let column_target_cumulative_count=$column_target_cumulative_count+curcount
      #fi

      # dlm temp find me
      #p_val=$i

      p_val=$j
      active_id=$p_val
#      declare "flag_$active_id"=0

      #let myvalue=$column_cumulative_count

      let myvalue=$column_target_cumulative_count

       #echo declaring $j $myvalue

#      declare "flag_$active_id"=$myvalue

#      declare "flag_$active_id"=$myvalue

      mytmpvar="flag_$active_id"
     
      #echo 1111
      #echo "${!mytmpvar}"
      #echo 222222
      #declare "$mytmpvar"=$mytmpvar+200
      #let othertmp="${!mytmpvar}"+200

      let othertmp="${!mytmpvar}"+$curcount

      #declare "$mytmpvar"="${!mytmpvar}"+200

      declare "$mytmpvar"=$othertmp

      #echo "${!mytmpvar}"
      #echo 3333333
       


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

      if [ -f  $DEST_FILE_TAG* ] ; then
        echo file exists! >/dev/null
      else
        echo file NO exists! >/dev/null
        curcount="----"
      fi 2>/dev/null
    fi
    
    # append count to the row string
    row="$row  $curcount"

  done # continue to next target

  # append the cumulative row total to the row output
  row="$row ............................ $row_cumulative"

  echo $row
  echo $row >> $TAGA_DIR/counts.txt
  echo $row >> $TAGA_DIR/countsReceives.txt
 
  # dlm temp find me
  #p_val=$i
  #active_id=$p_val
  ##let myvalue=$column_cumulative_count
  #let myvalue=$column_target_cumulative_count
  #declare "flag_$active_id"=$myvalue

done


# Build the final (Totals) row
#for target in $targetList
#do
#  # init the columns cumulative
#  let i=$i+1
#  column_cumulative=$column_cumulative" "
#  column_cumulative=$column_cumulative" "$i.pt
#
#  v="flag_$active_id"
#
#done
#


let count=0
for target in $targetList
do
  let count=$count+1
done

column_cumulative=""
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
do 

  v="flag_$i"

  value=`echo "${!v}"`

  let valuelen=`echo $value | awk '{print length($0)}'`

  # pad it
  if [ $valuelen -eq 3 ] ; then
     value=0$value
  elif [ $valuelen -eq 2 ] ; then
     value=00$value
  elif [ $valuelen -eq 1 ] ; then
     value=000$value
  else
     echo nothing to pad >/dev/null
  fi

  #column_cumulative=$column_cumulative" "`echo "${!v}"`
  column_cumulative=$column_cumulative" "$value

  let count=$count-1
  if [ $count -eq 0 ] ; then
    break
  fi

done

#column_cumulative=$column_cumulative"............................. "`echo "${!v}"`
column_cumulative=$column_cumulative" ............................ "$column_cumulative_count

# Print a space
echo 
echo >> $TAGA_DIR/counts.txt
echo >> $TAGA_DIR/countsReceives.txt

# Print the final (Totals) row
row="Receiver Totals:.  $column_cumulative"
echo $row
echo $row >> $TAGA_DIR/counts.txt
echo $row >> $TAGA_DIR/countsReceives.txt

echo
