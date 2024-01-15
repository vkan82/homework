#!/bin/bash

function list_process {
  for pid in $*
   do
     procpid=/proc/$pid
     if [[ -e $procpid/environ && -e $procpid/stat ]]; then
      
      # TIME in ps is (utime+stime)/CLK_TCK - (14) utime, (15) stime from /proc/$pid/stat
      Time=`awk -v ticks="$(getconf CLK_TCK)" '{print strftime ("%M:%S", ($14+$15)/ticks)}' $procpid/stat`      
      
      # Memory Locks
      Locked=`grep VmFlags $procpid/smaps | grep lo`
      
      #STAT данные из /proc/$pid/stat 
      
      Stats=`awk '{ printf $3; \
      if ($19<0) {printf "<" } else if ($19>0) {printf "N"}; \
      if ($6 == $1) {printf "s"}; \
      if ($20>1) {printf "l"}}' $procpid/stat; \
      [[ -n $Locked ]] && printf "L"; \
      awk '{ if ($8!=-1) { printf "+" }}' $procpid/stat`
      
      # содержание из /proc/$pid/cmdline или /proc/$pid/stat

      Cmdline=`awk '{ print $1 }' $procpid/cmdline | sed 's/\x0/ /g'`
      [[ -z $Cmdline ]] && Cmdline=`strings -s' ' $procpid/stat | awk '{ printf $2 }' | sed 's/(/[/; s/)/]/'`
      
      # TTY парсится из /proc/$pid/fd
      qq=`ls -l $procpid/fd/ | grep -E '\/dev\/tty|pts' | cut -d\/ -f3,4 | uniq`
      Tty=`awk '{ if ($7 == 0) {printf "?"} else { printf "'"$qq"'" }}' $procpid/stat`
    
    fi
    # вывод
    printf  '%7d %-7s %-12s %s %-10s\n' "$pid" "$Tty" "$Stats" "$Time" "$Cmdline"
  done
}
ALLPIDS=`ls /proc | grep -P ^[0-9] | sort -n | xargs`
printf  '%7s %-7s %-12s %s %-10s\n' "PID" "TTY" "STAT" "TIME" "COMMAND"
list_process $ALLPIDS
