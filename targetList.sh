#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################


# Set to 1 if at home, set to 0 otherwise
if ifconfig | grep 10\\.0\\.0 >/dev/null; then
  HOMELOCATION=1
else
  HOMELOCATION=0
fi

# Network Address Subnet Address Part
if [ $HOMELOCATION -eq 1 ] ; then
  NETADDRPART=10.0.0
else
  NETADDRPART=192.168.43
fi

# Home Location List
HOMELIST="localhost"
HOMELIST="10.0.0.18 10.0.0.27 " 
HOMELIST="10.0.0.18 10.0.0.20 10.0.0.21 10.0.0.22 10.0.0.27 " 
HOMELIST="10.0.0.18 10.0.0.20 10.0.0.21 10.0.0.22 10.0.0.27 " 

# Work Location List
WORKLIST="localhost"
WORKLIST="192.168.43.6 192.168.43.188 192.168.43.228" 
WORKLIST="192.168.43.6 192.168.43.188 " 
WORKLIST="192.168.43.6 192.168.43.69 192.168.43.157 192.168.43.188 192.168.43.208" 
WORKLIST="192.168.43.6 192.168.43.188 192.168.43.208" 

if [ $HOMELOCATION -eq 1 ] ; then
  TARGET_LIST=$HOMELIST
else
  TARGET_LIST=$WORKLIST
fi

################################
# IBOA Network Overrides
################################
IBOALOCATION=1
IBOALOCATION=0
if [ $IBOALOCATION -eq 1 ] ; then
  NETADDRPART=10.42.0
  IBOALIST="10.42.0.1 10.42.0.56"
  TARGET_LIST=$IBOALIST
fi

# IBOA
# Deployment Mode 1 (Embedded), Admin Host List is same as Target List
ADMIN_HOST_LIST=$TARGET_LIST
# IBOA
# Deployment Mode 2 (External), Admin Host List is orthogonal to Target List
#ADMIN_HOST_LIST=TBD_BASED_ON_LAB_ENVIRON

echo $TARGET_LIST 

