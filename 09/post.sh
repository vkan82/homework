#!/bin/bash
sudo su
if

./main_grep.sh ./access.log > report.txt &&
mailx v.kan@gsgroup.it < report.txt && rm report.txt

then
exit 0
else 
echo "file not found"
fi
