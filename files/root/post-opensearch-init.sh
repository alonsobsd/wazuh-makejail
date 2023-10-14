#!/bin/sh
#
echo " "
echo -e "\e[1;37m Generating admin password ...\e[0m"
echo " "

sleep 30

adminpass=$(openssl rand -base64 12 | sed 's/^/@/g')
agentpass=$(openssl rand -base64 20 | sed 's/^/@/g')
kibanapass=$(openssl rand -base64 12 | sed 's/^/@/g')

adminnewhash=$(sh -c "OPENSEARCH_JAVA_HOME=/usr/local/openjdk17 bash /usr/local/lib/opensearch/plugins/opensearch-security/tools/hash.sh -p ${adminpass} | sed -e /^*/d")
kibananewhash=$(sh -c "OPENSEARCH_JAVA_HOME=/usr/local/openjdk17 bash /usr/local/lib/opensearch/plugins/opensearch-security/tools/hash.sh -p ${kibanapass} | sed -e /^*/d")

adminoldhash=$(cat /usr/local/etc/opensearch/opensearch-security/internal_users.yml | sed -ne '/^admin:/,/description/p' | grep hash | cut -d '"' -f2)
kibanaoldhash=$(cat /usr/local/etc/opensearch/opensearch-security/internal_users.yml | sed -ne '/^kibanaserver:/,/description/p' | grep hash | cut -d '"' -f2)

echo ${agentpass} > /var/ossec/etc/authd.pass

sed -e "s,${adminoldhash},${adminnewhash},g" -i "" /usr/local/etc/opensearch/opensearch-security/internal_users.yml
sed -e "s,${kibanaoldhash},${kibananewhash},g" -i "" /usr/local/etc/opensearch/opensearch-security/internal_users.yml

sed -e "s,%%OPENSEARCH_ADMIN_PASS%%,${adminpass},g" -i "" /usr/local/etc/logstash/logstash.conf
sed -e "s,%%OPENSEARCH_ADMIN_PASS%%,${adminpass},g" -i "" /usr/local/etc/opensearch-dashboards/opensearch_dashboards.yml

sh -c "OPENSEARCH_JAVA_HOME=/usr/local/openjdk17 bash /usr/local/lib/opensearch/plugins/opensearch-security/tools/securityadmin.sh -cd /usr/local/etc/opensearch/opensearch-security/ -cacert /usr/local/etc/opensearch/certs/root-ca.pem -cert /usr/local/etc/opensearch/certs/admin.pem -key /usr/local/etc/opensearch/certs/admin-key.pem -h %{SERVER_IP} -p 9200 -icl -nhnv"

echo " "
echo -e "\e[1;37m ################################################ \e[0m"
echo -e "\e[1;37m Wazuh dashboard admin credentials                \e[0m"
echo -e "\e[1;37m Hostname : https://jail-host-ip:5601/app/wazuh   \e[0m"
echo -e "\e[1;37m Username : admin                                 \e[0m"
echo -e "\e[1;37m Password : ${adminpass}                          \e[0m"
echo -e "\e[1;37m ################################################ \e[0m"
echo -e "\e[1;37m Wazuh agent enrollment password                  \e[0m"
echo -e "\e[1;37m Password : ${agentpass}                          \e[0m"
echo -e "\e[1;37m ################################################ \e[0m"
echo " "

sleep 10

echo " "
echo -e " \e[1;37m Passwords generated ...\e[0m"
echo " "
