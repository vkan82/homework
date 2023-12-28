#!/bin/bash
. ./at_hour.sh
. ./to_hour.sh
. ./rows_at_hour.sh

# дата и время с которого будет выборка
AT_HOUR=$(hour)

# дата и время AT_HOUR + 1 час
TO_HOUR=$(hour1)

# Проверка на переданный параметр
USAGE="Pls, rows_at_hour.sh LOG_FILE"
if [ -z "$1" ]
then
  echo "Sorry, there is no first parameter LOG_FILE."
  echo $USAGE
  exit 1
fi

LOG_FILE="${1}"

DEBUG=0
if [ "${DEBUG}" = "1" ]
then
  echo USE LOG FILE $LOG_FILE
fi

#0
echo "Временной диапазон:" $AT_HOUR "-" $TO_HOUR

#1 URN
echo "Топ-10 клиентских URL запрашиваемых с этого сервера"
rows_at_hour | awk '{print $7}' | sort | uniq -c | sort -rn | head -n 10 > 1.1.txt && cat 1.1.txt &&
echo "------------------------------------------------------" 
#2 IP
echo "Топ-10 клиентских IP"
rows_at_hour  | awk '{print $1}' | sort | uniq -c | sort -rn | head -n 10 > 2.2.txt && tail -n 10 2.2.txt &&
echo "------------------------------------------------------"
#3 запросы-ответы
echo "Все коды состояния HTTP и их количество"
rows_at_hour | awk '{print $9}'| grep -v "-" | sort | uniq -c | sort -rn > 3.3.txt && cat 3.3.txt && 
echo "------------------------------------------------------" 
#4 ошибки серверные 5** и клиентские 4**
echo "Все коды состояния  4xx и 5xx"
rows_at_hour | awk '{print $9}' | grep ^4 > 4.4.txt && rows_at_hour | awk '{print $9}' | grep ^5 >> 4.4.txt && cat 4.4.txt | uniq -d -c | sort -rn > 4.5.txt && cat 4.5.txt 
echo "------------------------------------------------------"
echo "all"
rm -f 1.1.txt 2.2.txt 3.3.txt 4.4.txt 4.5.txt
