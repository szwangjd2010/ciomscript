#!/bin/sh

while getopts ud opt
do
    case $opt in
        u)  type=urls;;
        d)  type=dirs;;
    esac
done

cat $2 | while read line
do
  echo "curl -s http://ccms.chinacache.com/index.jsp?user=yunxuetang&pswd=PhmqWhx12DOd&ok=ok&$type=$line"
  curl -s "http://ccms.chinacache.com/index.jsp?user=yunxuetang&pswd=PhmqWhx12DOd&ok=ok&$type=$line"
done
