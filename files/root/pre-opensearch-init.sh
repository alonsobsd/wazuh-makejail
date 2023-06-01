#!/bin/sh
#
echo " "
echo -e "\e[1;37m Installing logstash-output-opensearchplugin ...\e[0m"
echo " "

cd /usr/local/logstash/bin; sh -c "JAVA_HOME=/usr/local/openjdk11 ./logstash-plugin install logstash-output-opensearch"

echo " "
echo -e "\e[1;37m Copy opensearch config sample files ...\e[0m"
echo " "

cd /usr/local/etc/opensearch/opensearch-security; sh -c 'for i in $(ls *.sample ) ; do cp -p ${i} $(echo ${i} | sed "s|.sample||g") ; done'
