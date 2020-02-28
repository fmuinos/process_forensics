#!/bin/bash

# Find the <pids> with ssh connections.
pids=$(find /proc -name environ -maxdepth 2 -type f 2>/dev/null | xargs grep -o "SSH_CLIENT" 2>/dev/null | awk '{print $6}' | awk -F/ '{print $3}')
echo -e "Found process with ssh conections..."

mkdir -p recovered
# cp the binaries to backup dir
echo "pid|command|path|oldpath|args|sha1|ipsrc|portsrc|ipdst|portdst" > "extract.txt"
for i in $pids
do
   mkdir -p "recovered/${i}"
   comm=$(cat "/proc/${i}/comm")
   argstmp=$(tr -d '\0' <"/proc/${i}/cmdline")
   sha1=$(sha1sum "/proc/${i}/exe" | awk '{print $1}')
   commpath=$(strings "/proc/${i}/environ" | grep -E -i "^pwd" | awk -F= '{print $2}' )
   oldpath=$(strings "/proc/${i}/environ" | grep -E -i "^oldpwd" | awk -F= '{print $2}' )
   iptmp=$( strings "/proc/${i}/environ" | grep -i "ssh_connection" | awk -F= '{print $2}')
   ipsrc=$(echo "$iptmp" | awk '{print $1}')
   portsrc=$(echo "$iptmp" | awk '{print $2}')
   ipdst=$(echo "$iptmp" | awk '{print $3}')
   portdst=$(echo "$iptmp" | awk '{print $4}')
   cp "/proc/${i}/exe" "recovered/${i}/$comm"
   if [ "$EUID" -eq 0 ];then
	cp "/proc/${i}/environ" "/proc/${i}/maps" "/proc/${i}/stack" "/proc/${i}/status" "recovered/${i}/"
   else
	echo "[warning] Please run as root"
   fi
   echo "pid: $i - $comm - $commpath - $oldpath - $argstmp - $sha1 - $ipsrc:$portsrc -> $ipdst:$portdst"
   echo "$i|$comm|$commpath|$oldpath|$argstmp|$sha1|$ipsrc|$portsrc|$ipdst|$portdst" >> "extract.txt"
done
